
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * @author wlloyd
 */
public class Response {
	String value, uuid, error;
	long cpuUsr, cpuKrn, cutime, cstime;
	int pid, newcontainer;
	long vmcpuusr, vmcpunice, vmcpukrn, vmcpuidle, vmcpuiowait;
	long vmcpuirq, vmcpusirq, vmcpusteal, vmuptime;
	String output;
	long wallTime;

	public Response() {
	}

	public Response(String value, String uuid) {
		this.value = value;
		this.uuid = uuid;
	}

	public Response(String value, String uuid, long cpuusr, long cpukrn) {
		this.value = value;
		this.uuid = uuid;
		this.cpuUsr = cpuusr;
		this.cpuKrn = cpukrn;
	}

	public Response(String value, String uuid, long cpuusr, long cpukrn, long cutime, long cstime) {
		this.value = value;
		this.uuid = uuid;
		this.cpuUsr = cpuusr;
		this.cpuKrn = cpukrn;
		this.cutime = cutime;
		this.cstime = cstime;
	}

	public Response(String value, String uuid, long cpuusr, long cpukrn, long cutime, long cstime, long vmcpuusr,
			long vmcpunice, long vmcpukrn, long vmcpuidle, long vmcpuiowait, long vmcpuirq, long vmcpusirq,
			long vmcpusteal, long vuptime, int newcontainer, String output, long wallTime) {

		this.value = value;
		this.uuid = uuid;
		this.cpuUsr = cpuusr;
		this.cpuKrn = cpukrn;
		this.cutime = cutime;
		this.cstime = cstime;
		this.vmcpuusr = vmcpuusr;
		this.vmcpunice = vmcpunice;
		this.vmcpukrn = vmcpukrn;
		this.vmcpuidle = vmcpuidle;
		this.vmcpuiowait = vmcpuiowait;
		this.vmcpuirq = vmcpuirq;
		this.vmcpusirq = vmcpusirq;
		this.vmcpusteal = vmcpusteal;
		this.vmuptime = vuptime;
		this.newcontainer = newcontainer;

		this.output = output;
		this.wallTime = wallTime;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public String getUuid() {
		return uuid;
	}

	public void setUuid(String uuid) {
		this.uuid = uuid;
	}

	public long getCpuUsr() {
		return cpuUsr;
	}

	public void setCpuUsr(long cpuusr) {
		this.cpuUsr = cpuusr;
	}

	public long getCpuKrn() {
		return cpuKrn;
	}

	public void setCpuKrn(long cpukrn) {
		this.cpuKrn = cpukrn;
	}

	public long getCuTime() {
		return cutime;
	}

	public void setCuTime(long cutime) {
		this.cutime = cutime;
	}

	public long getCsTime() {
		return cstime;
	}

	public void setCsTime(long cstime) {
		this.cstime = cstime;
	}

	public String getError() {
		return error;
	}

	public void setError(String err) {
		this.error = err;
	}

	public int getPid() {
		return pid;
	}

	public void setPid(int pid) {
		this.pid = pid;
	}

	public long getVmcpuusr() {
		return vmcpuusr;
	}

	public void setVmCpuusr(long vmcpuusr) {
		this.vmcpuusr = vmcpuusr;
	}

	public long getVmcpunice() {
		return vmcpunice;
	}

	public void setVmcpunice(long vmcpunice) {
		this.vmcpunice = vmcpunice;
	}

	public long getVmcpukrn() {
		return vmcpukrn;
	}

	public void setVmcpukrn(long vmcpukrn) {
		this.vmcpukrn = vmcpukrn;
	}

	public long getVmcpuidle() {
		return vmcpuidle;
	}

	public void setVmcpuidle(long vmcpuidle) {
		this.vmcpuidle = vmcpuidle;
	}

	public long getVmcpuiowait() {
		return vmcpuiowait;
	}

	public void setVmcpuiowait(long vmcpuiowait) {
		this.vmcpuiowait = vmcpuiowait;
	}

	public long getVmcpuirq() {
		return vmcpuirq;
	}

	public void setVmcpuirq(long vmcpuirq) {
		this.vmcpuirq = vmcpuirq;
	}

	public long getVmcpusirq() {
		return vmcpusirq;
	}

	public void setVmcpusirq(long vmcpusirq) {
		this.vmcpusirq = vmcpusirq;
	}

	public long getVmcpusteal() {
		return vmcpusteal;
	}

	public void setVmcpusteal(long vmcpusteal) {
		this.vmcpusteal = vmcpusteal;
	}

	public long getVmuptime() {
		return this.vmuptime;
	}

	public void setVmuptime(long vmuptime) {
		this.vmuptime = vmuptime;
	}

	public int getNewcontainer() {
		return this.newcontainer;
	}

	public void setNewcontainer(int newcontainer) {
		this.newcontainer = newcontainer;
	}

	public String getOutput() {
		return this.output;
	}

	public void setOutput(String output) {
		this.output = output;
	}

	public long getWallTime() {
		return this.wallTime;
	}

	public void setWallTime(long wallTime) {
		this.wallTime = wallTime;
	}

	@Override
	public String toString() {
		return "value=" + this.getValue() + "\nnewconatiner=" + this.newcontainer + "\nuuid=" + this.getUuid()
				+ "\ncpuusr=" + this.getCpuUsr() + "\ncpukrn=" + this.getCpuKrn() + "\ncutime=" + this.getCuTime()
				+ "\ncstime=" + this.getCsTime() + "\nvmuptime=" + this.getVmuptime() + "\nvmcpusteal="
				+ this.getVmcpusteal() + "\nvmcpuusr=" + this.getVmcpuusr() + "\nvmcpukrn=" + this.getVmcpukrn()
				+ "\nvmcpuidle=" + this.getVmcpuidle() + "\noutput=" + this.output + "\nwalltime=" + this.wallTime;
	}
}
