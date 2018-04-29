import java.util.ArrayList;

public class SpecResult {
	private String bmName;
	private String threadCount;
	private String warmupScore;
	private String score;
	private ArrayList<String> iteScores;
	private long totalDuration;

	public SpecResult(String bmName, String threadCount, String warmupScore, String score, ArrayList<String> ite,
			long totalDuration) {
		this.bmName = bmName;
		this.threadCount = threadCount;
		this.warmupScore = warmupScore;
		this.score = score;
		this.iteScores = ite;
		this.totalDuration = totalDuration;
	}

	public String getBmName() {
		return this.bmName;
	}

	public String getThreadCount() {
		return this.threadCount;
	}

	public String getWarmupScore() {
		return this.warmupScore;
	}

	public String getScore() {
		return this.score;
	}

	public ArrayList<String> getIteScores() {
		return this.iteScores;
	}

	public long getTotalDuration() {
		return this.totalDuration;
	}
}