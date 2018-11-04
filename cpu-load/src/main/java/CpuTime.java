import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/*
* @author wlloyd
*/
public class CpuTime {
	long utime;
	long stime;
	long cutime;
	long cstime;

	public CpuTime() {
	}

	CpuTime(long utime, long stime, long cutime, long cstime) {
		this.utime = utime;
		this.stime = stime;
		this.cutime = cutime;
		this.cstime = cstime;
	}

	@Override
	public String toString() {
		return "utime=" + utime + " stime=" + stime + " cutime=" + cutime + " cstime=" + cstime + " ";
	}

	public static CpuTime getCpuUtilization() {
		String filename = "/proc/1/stat";
		File f = new File(filename);
		Path p = Paths.get(filename);
		String text = "";
		StringBuffer sb = new StringBuffer();
		if (f.exists()) {
			try (BufferedReader br = Files.newBufferedReader(p)) {
				text = br.readLine();
				br.close();
			} catch (IOException ioe) {
				sb.append("Error reading file=" + filename);
			}
			String params[] = text.split(" ");
			return new CpuTime(Long.parseLong(params[13]), Long.parseLong(params[14]), Long.parseLong(params[15]),
					Long.parseLong(params[16]));
		} else
			return new CpuTime();
	}

	public static CpuTime getCpuTimeDiff(CpuTime c1, CpuTime c2) {
		return new CpuTime(c2.utime - c1.utime, c2.stime - c1.stime, c2.cutime - c1.cutime, c2.cstime - c1.cstime);
	}
}
