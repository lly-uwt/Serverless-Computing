import com.amazonaws.services.lambda.runtime.ClientContext;
import com.amazonaws.services.lambda.runtime.CognitoIdentity;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;

public class Main {
    public static void main(String[] args) {
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
