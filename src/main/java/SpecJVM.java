import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.Scanner;

public class SpecJVM {
	public static SpecResult run(String[] args) {
		
		OutputCapturer.start();
		long timestamp = System.currentTimeMillis();
		spec.harness.Launch.main(args);
        timestamp = System.currentTimeMillis() - timestamp;
		String output = OutputCapturer.stop();
		
		Scanner scanner = new Scanner(output);

		int i = 1;
		String warmupScore = "", score = "", threads = "";
		ArrayList<String> ite = new ArrayList<String>();
		
		while (scanner.hasNextLine()) {
			String line = scanner.nextLine();
			if (line.indexOf("Warmup") != -1 && line.indexOf("result") != -1)
				warmupScore = line.substring(line.indexOf(":") + 1, line.indexOf(" ops")).trim();
			else if (line.indexOf("Iteration") != -1 && line.indexOf("result") != -1) {
				ite.add(line.substring(line.indexOf(":") + 1, line.indexOf(" o")).trim());
				i++;
			} else if (line.indexOf("Score") != -1)
				score = line.substring(line.indexOf(":") + 1, line.indexOf(" ops")).trim();
			else if (line.indexOf("Threads") != -1)
				threads = line.substring(line.indexOf(":") + 1).trim();
		}

		return new SpecResult(args[0], threads, warmupScore,score, ite, timestamp);
	}
}
