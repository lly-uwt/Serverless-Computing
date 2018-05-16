import com.amazonaws.services.lambda.runtime.ClientContext;
import com.amazonaws.services.lambda.runtime.CognitoIdentity;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;

public class Main {
    public static void main(String[] args) {
//        test();
        run(args);
    }

    private static void run(String[] args) {
        Context c = getContext();
        Request req = new Request();

        req.setName(args[0]);
        req.setBt(args[1]);
        req.setWt(args[2]);
        req.setI(args[3]);
        req.setIt(args[4]);
        
        FunctionHandler funcHandler = new FunctionHandler();
        Response response = funcHandler.handleRequest(req, c);
        System.out.println(response.toString());
    }

    private static void test() {
        String[] params = new String[13];
        params[0] = "scimark.fft.small";
        params[1] = "-ict";
        params[2] = "-ikv";
        params[3] = "-crf";
        params[4] = "false";
        params[5] = "-bt";
        params[6] = "2";
        params[7] = "-wt";
        params[8] = "3";
        params[9] = "-i";
        params[10] = "1";
        params[11] = "-it";
        params[12] = "5";
        spec.harness.Launch.main(params);
    }

    private static Context getContext() {
        return new Context() {
            @Override
            public String getAwsRequestId() {
                return "";
            }

            @Override
            public String getLogGroupName() {
                return "";
            }

            @Override
            public String getLogStreamName() {
                return "";
            }

            @Override
            public String getFunctionName() {
                return "";
            }

            @Override
            public String getFunctionVersion() {
                return "";
            }

            @Override
            public String getInvokedFunctionArn() {
                return "";
            }

            @Override
            public CognitoIdentity getIdentity() {
                return null;
            }

            @Override
            public ClientContext getClientContext() {
                return null;
            }

            @Override
            public int getRemainingTimeInMillis() {
                return 0;
            }

            @Override
            public int getMemoryLimitInMB() {
                return 0;
            }

            @Override
            public LambdaLogger getLogger() {
                return new LambdaLogger() {

                    @Override
                    public void log(byte[] arg0) {
                        // TODO Auto-generated method stub
                        
                    }

                    @Override
                    public void log(String arg0) {
                        // TODO Auto-generated method stub
                        
                    }
                };
            }
        };
    }
}
