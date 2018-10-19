
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
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class FunctionHandler implements RequestHandler<Request, Response> {

	private int newContainer = -1;
	private String uuid;
	private List<Process> pArray = new ArrayList<Process>();
	private int inputChilds;
	private final int DURATION = 50000;
	private final int STEP = 1000;

	public Response handleRequest(Request request, Context context) {
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

		LambdaLogger logger = context.getLogger();
		CpuTime c1 = CpuTime.getCpuUtilization();
		VmCpuStat v1 = VmCpuStat.getVmCpuStat();

		long wallTime = System.currentTimeMillis();
		inputChilds = request.getInputChilds();
		try {
			spawnChilds();
			collectPsData();
		} catch (IOException e) {
			logger.log(e.toString());
			e.printStackTrace();
		}
		wallTime = System.currentTimeMillis() - wallTime;

		CpuTime c2 = CpuTime.getCpuUtilization();
		VmCpuStat v2 = VmCpuStat.getVmCpuStat();

		CpuTime cused = CpuTime.getCpuTimeDiff(c1, c2);
		VmCpuStat vused = VmCpuStat.getVmCpuStatDiff(v1, v2);

		long vuptime = VmCpuStat.getUpTime(v2);
		return new Response(LocalDateTime.now().toString(), uuid, cused.utime, cused.stime, cused.cutime, cused.cstime,
				vused.cpuusr, vused.cpunice, vused.cpukrn, vused.cpuidle, vused.cpuiowait, vused.cpuirq, vused.cpusirq,
				vused.cpusteal, vuptime, newContainer, wallTime);
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
					// read the output from the command
					while ((s = stdInput.readLine()) != null) {
					    System.out.println(s);
					}

					// read any errors from the attempted command
					while ((s = stdError.readLine()) != null) {
					    System.out.println(s);
					}
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}, STEP, STEP);
	}
}
