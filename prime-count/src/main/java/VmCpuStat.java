import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/*
* @author wlloyd
*/
class VmCpuStat {
	long cpuusr;
	long cpunice;
	long cpukrn;
	long cpuidle;
	long cpuiowait;
	long cpuirq;
	long cpusirq;
	long cpusteal;
	long btime;

	VmCpuStat() {
	}

	VmCpuStat(long cpuusr, long cpunice, long cpukrn, long cpuidle,
			long cpuiowait, long cpuirq, long cpusirq, long cpusteal) {
		this.cpuusr = cpuusr;
		this.cpunice = cpunice;
		this.cpukrn = cpukrn;
		this.cpuidle = cpuidle;
		this.cpuiowait = cpuiowait;
		this.cpuirq = cpuirq;
		this.cpusirq = cpusirq;
		this.cpusteal = cpusteal;
	}

	public static VmCpuStat getVmCpuStat() {
		String filename = "/proc/stat";
		File f = new File(filename);
		Path p = Paths.get(filename);
		String text = "";
		StringBuffer sb = new StringBuffer();
		if (f.exists()) {
			try (BufferedReader br = Files.newBufferedReader(p)) {
				text = br.readLine();
				String params[] = text.split(" ");
				VmCpuStat vcs = new VmCpuStat(Long.parseLong(params[2]),
						Long.parseLong(params[3]), Long.parseLong(params[4]),
						Long.parseLong(params[5]), Long.parseLong(params[6]),
						Long.parseLong(params[7]), Long.parseLong(params[8]),
						Long.parseLong(params[9]));
				while ((text = br.readLine()) != null && text.length() != 0) {
					// get boot time in ms since epoch
					if (text.contains("btime")) {
						String prms[] = text.split(" ");
						vcs.btime = Long.parseLong(prms[1]);
					}
				}
				br.close();
				return vcs;
			} catch (IOException ioe) {
				sb.append("Error reading file=" + filename);
				return new VmCpuStat();
			}
		} else
			return new VmCpuStat();
	}

	public static long getUpTime(VmCpuStat vmcpustat) {
		// double time = vmcpustat.cpuidle +
		// vmcpustat.cpuiowait +
		// vmcpustat.cpuirq +
		// vmcpustat.cpukrn +
		// vmcpustat.cpunice +
		// vmcpustat.cpusirq +
		// vmcpustat.cpusteal +
		// vmcpustat.cpuusr;
		// time = time / 100;
		// time = time / 2;
		return vmcpustat.btime;
		// return time;
	}

	public static VmCpuStat getVmCpuStatDiff(VmCpuStat v1, VmCpuStat v2) {
		return new VmCpuStat(v2.cpuusr - v1.cpuusr, v2.cpunice - v1.cpunice,
				v2.cpukrn - v1.cpukrn, v2.cpuidle - v1.cpuidle,
				v2.cpuiowait - v1.cpuiowait, v2.cpuirq - v1.cpuirq,
				v2.cpusirq - v1.cpusirq, v2.cpusteal - v1.cpusteal);
	}
}
