
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import org.json.JSONArray;
import org.json.JSONObject;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class FunctionHandler implements RequestHandler<Request, Response> {

	private int newContainer = -1;
	private String uuid;
	private LambdaLogger logger;
	private List<Process> pArray = new ArrayList<Process>();
	private JSONArray jArray = new JSONArray();
	private int inputChilds;
	private int count = 0;
	private final int DURATION = 30000;
	private final int STEP = 1000;

	public Response handleRequest(Request request, Context context) {
		String os = System.getProperty("os.name");
		if (!os.toLowerCase().contains("windows")) {
			uuid = "unset";
			File f = new File("/tmp/container-id");
			Path p = Paths.get("/tmp/container-id");
			if (f.exists()) {
				newContainer = 0;
				try (BufferedReader br = Files.newBufferedReader(p)) {
					uuid = br.readLine();
					br.close();
				} catch (IOException ioe) {
					return new Response("Error reading existing UUID", uuid);
				}
			} else {
				newContainer = 1;
				try (BufferedWriter bw = Files.newBufferedWriter(p, StandardCharsets.US_ASCII,
						StandardOpenOption.CREATE_NEW)) {
					uuid = UUID.randomUUID().toString();
					bw.write(uuid);
					bw.close();
				} catch (IOException ioe) {
					return new Response("Error reading existing UUID", uuid);
				}
			}
		}

		logger = context.getLogger();
		CpuTime c1 = CpuTime.getCpuUtilization();
		VmCpuStat v1 = VmCpuStat.getVmCpuStat();

		long wallTime = System.currentTimeMillis();
		inputChilds = request.getInputChilds();
		try {
			spawnChilds();
			collectPsData();
			Thread.sleep(DURATION);
		} catch (IOException | InterruptedException e) {
			logger.log(e.toString());
			e.printStackTrace();
		}
//		System.out.println(jArray.toString());
		String output = jArray.toString();
		wallTime = System.currentTimeMillis() - wallTime;

		CpuTime c2 = CpuTime.getCpuUtilization();
		VmCpuStat v2 = VmCpuStat.getVmCpuStat();

		CpuTime cused = CpuTime.getCpuTimeDiff(c1, c2);
		VmCpuStat vused = VmCpuStat.getVmCpuStatDiff(v1, v2);

		long vuptime = VmCpuStat.getUpTime(v2);
		return new Response(LocalDateTime.now().toString(), uuid, cused.utime, cused.stime, cused.cutime, cused.cstime,
				vused.cpuusr, vused.cpunice, vused.cpukrn, vused.cpuidle, vused.cpuiowait, vused.cpuirq, vused.cpusirq,
				vused.cpusteal, vuptime, newContainer, output, wallTime);
	}

	private void spawnChilds() throws IOException {
		for (int i = 0; i < inputChilds; i++) {
			Process p = Runtime.getRuntime().exec(new String[] { "sha1sum", "/dev/zero", "&" });
			pArray.add(p);
		}
	}

	private void collectPsData() {

		Timer timerStep = new Timer();
		Timer timerDuration = new Timer();
		timerDuration.schedule(new TimerTask() {
			@Override
			public void run() {
				timerStep.cancel();
				for (Process p : pArray) {
					p.destroy();
				}
				timerDuration.cancel();
			}
		}, DURATION);
		timerStep.scheduleAtFixedRate(new TimerTask() {
			@Override
			public void run() {
				try {
					Process p = Runtime.getRuntime().exec(new String[] { "ps", "-o", "pid,%cpu,cpuid,comm" });
					BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
					BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));

					String s = null;
					double totalPCPU = 0, cpu0 = 0, cpu1 = 0, javaOverhead = 0;
					boolean firstLine = true;
					ArrayList<String> procsArr = new ArrayList<String>();
					while ((s = stdInput.readLine()) != null) {
						if (firstLine) {
							firstLine = false;
							continue;
						}
						StringTokenizer st = new StringTokenizer(s);
						ArrayList<String> strArray = new ArrayList<String>();
						while (st.hasMoreTokens()) {
							strArray.add(st.nextToken());
						}

						int pid = Integer.parseInt(strArray.get(0));
						double cpu = Double.parseDouble(strArray.get(1));
						int cpuid = Integer.parseInt(strArray.get(2));
						String cmd = strArray.get(3);
						
						totalPCPU += cpu;
				        if (cmd.equals("java"))
				            javaOverhead = cpu;
						if (cpuid == 0)
							cpu0 += cpu;
						else
							cpu1 += cpu;
						procsArr.add(String.format("pid:%d-%%cpu:%s-cpuid:%d-cmd:%s", pid, "" + round2(cpu), cpuid, cmd));
					}
					JSONObject jo = new JSONObject();
					jo.put("index", ++count);
					jo.put("data", String.join(";", procsArr));
					jo.put("cpu0", round2(cpu0));
					jo.put("cpu1", round2(cpu1));
					jo.put("totalPCPU", round2(totalPCPU));
					jo.put("overhead", javaOverhead);
					jArray.put(jo);

					// read any errors from the attempted command
					while ((s = stdError.readLine()) != null) {
						logger.log(s);
					}
				} catch (IOException e) {
					logger.log(e.toString());
					e.printStackTrace();
				}
			}
		}, STEP, STEP);
	}

	private double round2(double number) {
		return (double) Math.round(number * 100) / 100;
	}
}
