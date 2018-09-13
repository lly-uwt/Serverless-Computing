
public class Request {
	private String name, id, bt, wt, i, it;

	public Request() {
	}

	public Request(String theName, String theBt, String theWt, String theI, String theIt) {
		this.name = theName;
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