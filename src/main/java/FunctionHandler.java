
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
import java.util.UUID;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class FunctionHandler implements RequestHandler<Request, Response> {
    private int newContainer;
    private String uuid;

    public Response handleRequest(Request request, Context context) {
        newContainer = 0;
        uuid = "unset";
        String[] args = new String[] { request.getName(), "-ict", "-ikv", "-crf",
                "false", "-ctf", "false", "-chf", "false", "-bt", request.getBt(),
                "-wt", request.getWt(), "-i", request.getI(), "-it",
                request.getIt() };
        // scimark.fft.small -ict -ikv -crf false -ctf false -chf false -bt 2 -wt 0
        // -i 1 -it 2

        uuid();
        LambdaLogger logger = context.getLogger();
        CpuTime c1 = CpuTime.getCpuUtilization();
        VmCpuStat v1 = VmCpuStat.getVmCpuStat();

        SpecResult specScore = SpecJVM.run(args);

        CpuTime c2 = CpuTime.getCpuUtilization();
        VmCpuStat v2 = VmCpuStat.getVmCpuStat();

        CpuTime cused = CpuTime.getCpuTimeDiff(c1, c2);
        VmCpuStat vused = VmCpuStat.getVmCpuStatDiff(v1, v2);

        long vuptime = VmCpuStat.getUpTime(v2);

//        String fileout = ((request.getName() != null)
//                && (request.getName().length() > 0))
//                        ? runCommand(request.getName(), context)
//                        : "";

        return new Response(LocalDateTime.now().toString(), uuid, cused.utime, cused.stime, cused.cutime,
                cused.cstime, vused.cpuusr, vused.cpunice, vused.cpukrn,
                vused.cpuidle, vused.cpuiowait, vused.cpuirq, vused.cpusirq,
                vused.cpusteal, vuptime, newContainer, specScore.getBmName(),
                specScore.getScore(), specScore.getThreadCount(),
                specScore.getTotalDuration());
    }

    void uuid() {
        File f = new File("/tmp/container-id");
        Path p = Paths.get("/tmp/container-id");
        if (f.exists()) {
            try (BufferedReader br = Files.newBufferedReader(p)) {
                uuid = br.readLine();
                br.close();
            } catch (IOException ioe) {
                throw new Error("Error reading existing UUID");
            }
        } else {
            newContainer = 1;
            try (BufferedWriter bw = Files.newBufferedWriter(p,
                    StandardCharsets.US_ASCII, StandardOpenOption.CREATE_NEW)) {
                uuid = UUID.randomUUID().toString();
                bw.write(uuid);
                bw.close();
            } catch (IOException ioe) {
                throw new Error("Error reading existing UUID");
            }
        }
    }

    public String runCommand(String sCommand, Context context) {
        StringBuffer sbOutput = new StringBuffer();
        try {
            sbOutput.append("COMMAND:");
            sbOutput.append(sCommand);
            Process p = Runtime.getRuntime().exec(sCommand);
            BufferedReader br = new BufferedReader(
                    new InputStreamReader(p.getInputStream()));
            sbOutput.append("  OUTPUT:");
            while (br.ready())
                sbOutput.append(br.readLine());
            sbOutput.append("  ERROR:");
            br.close();
            br = new BufferedReader(new InputStreamReader(p.getErrorStream()));
            while (br.ready())
                sbOutput.append(br.readLine());
            br.close();
            p.getOutputStream().close();
            p.getErrorStream().close();
            p.getInputStream().close();
            // p.destroy();
            // p.destroyForcibly();
            // p.destroyForcibly();
            // p.destroyForcibly();
            p.waitFor();
            sbOutput.append("  IS-ALIVE:" + p.isAlive());
            sbOutput.append("  EXIT-VAL:" + p.exitValue());
            sbOutput.append("  TIME-LEFT:" + context.getRemainingTimeInMillis());
            return sbOutput.toString();
        } catch (IOException ioe) {
            return "command " + sCommand + " failed.";
        } catch (InterruptedException ie) {
            return "process interrupted running " + sCommand + " ...";
        }
    }
}
