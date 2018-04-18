package handler;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Scanner;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class LambdaFunctionHandler implements RequestHandler<Request, String> {

	@Override
	public String handleRequest(Request input, Context context) {
		String id = input.getId();

		String[] arg = new String[13];
		String[] cpuCMD = new String[] { "/bin/sh", "-c", "cat /proc/cpuinfo | grep \"model name\" | head -n 1" };
		String[] procCMD = new String[] { "/bin/sh", "-c", "cat /proc/cpuinfo | grep processor | tail -n 1" };
		String[] freeCMD = new String[] { "/bin/sh", "-c", "free -m | grep Mem" };
		String[] diskCMD = new String[] { "/bin/sh", "-c", "df -h | head -n 2 | tail -n 1" };
		String[] kernelCMD = new String[] { "uname", "-a" };
		String[] osCMD = new String[] { "/bin/sh", "-c", "cat /etc/os-release | grep PRETTY | cut -c 14-40" };

		arg[0] = input.getName();
		arg[1] = "-ict";
		arg[2] = "-ikv";
		arg[3] = "-crf";
		arg[4] = "false";
		arg[5] = "-bt";
		arg[6] = input.getBt();
		arg[7] = "-wt";
		arg[8] = input.getWt();
		arg[9] = "-i";
		arg[10] = input.getI();
		arg[11] = "-it";
		arg[12] = input.getIt();

		OutputCapturer.start();
		spec.harness.Launch.main(arg);
		String output = OutputCapturer.stop();
		PrintWriter fileW = null;
		File file = null;
		try {
			file = File.createTempFile("temp", null);
			fileW = new PrintWriter(file);
		} catch (IOException e) {
			e.printStackTrace();
		}

		Scanner scanner = new Scanner(output);

		int i = 1;
		String warmupScore = "", score = "", threads = "";
		ArrayList<String> ite = new ArrayList<String>();
		fileW.print("ID,region,time,BM_name,Warmup_score_(" + input.getWt() + "s)(ops/m),");
		while (scanner.hasNextLine()) {
			String line = scanner.nextLine();
			if (line.indexOf("Warmup") != -1 && line.indexOf("result") != -1)
				warmupScore = line.substring(line.indexOf(":") + 1, line.indexOf(" ops")).trim();
			else if (line.indexOf("Iteration") != -1 && line.indexOf("result") != -1) {
				fileW.write("Iteration_" + i + "_(" + input.getIt() + "s)(ops/m),");
				ite.add(line.substring(line.indexOf(":") + 1, line.indexOf(" o")).trim());
				i++;
			} else if (line.indexOf("Score") != -1)
				score = line.substring(line.indexOf(":") + 1, line.indexOf(" ops")).trim();
			else if (line.indexOf("Threads") != -1)
				threads = line.substring(line.indexOf(":") + 1).trim();
		}
		fileW.println("BM_score(ops/m),Threads,CPU,OS,Kernel,Processor,Disk,Free");
		fileW.print(id + ",standard," + LocalTime.now() + "," + input.getName() + "," + warmupScore + ",");

		for (String temp : ite) {
			fileW.write(temp + ",");
		}
		try {
			String proc = sysInfoExe(procCMD);
			String cpu = sysInfoExe(cpuCMD);
			fileW.write(score + "," + threads + "," + cpu.substring(cpu.indexOf(":") + 2) + "," + sysInfoExe(osCMD)
					+ "," + sysInfoExe(kernelCMD) + "," + proc.substring(proc.indexOf(":") + 2) + ","
					+ sysInfoExe(diskCMD) + "," + sysInfoExe(freeCMD));
		} catch (IOException e) {
			e.printStackTrace();
		}
		fileW.close();

		String bucketName = "helloworld-us-standard";
		PutObjectRequest por = new PutObjectRequest(bucketName, id, file);
		por.setCannedAcl(CannedAccessControlList.PublicRead);
		AmazonS3 s3client = new AmazonS3Client();
		s3client.putObject(por);
		file.deleteOnExit();

		return id;

	}

	public String sysInfoExe(String[] cpuCMD) throws IOException {
		Process proc = null;
		String output = "";
		try {
			proc = Runtime.getRuntime().exec(cpuCMD);
		} catch (IOException e) {
			e.printStackTrace();
		}

		BufferedReader reader = new BufferedReader(new InputStreamReader(proc.getInputStream()));

		String line = "";
		try {
			while ((line = reader.readLine()) != null) {
				output += line;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

		try {
			proc.waitFor();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		reader.close();
		return output;
	}
}

class Request {
	String name, id, bt, wt, i, it;

	public Request() {
	}

	public Request(String theName, String theId, String theBt, String theWt, String theI, String theIt) {
		this.name = theName;
		this.id = theId;
		this.bt = theBt;
		this.wt = theWt;
		this.i = theI;
		this.it = theIt;
	}

	public void setName(String theName) {
		this.name = theName;
	}

	public String getName() {
		return this.name;
	}

	public void setId(String theId) {
		this.id = theId;
	}

	public String getId() {
		return this.id;
	}

	public void setBt(String theBt) {
		this.bt = theBt;
	}

	public String getBt() {
		return this.bt;
	}

	public void setWt(String theWt) {
		this.wt = theWt;
	}

	public String getWt() {
		return this.wt;
	}

	public void setI(String theI) {
		this.i = theI;
	}

	public String getI() {
		return this.i;
	}

	public void setIt(String theIt) {
		this.it = theIt;
	}

	public String getIt() {
		return this.it;
	}
}
