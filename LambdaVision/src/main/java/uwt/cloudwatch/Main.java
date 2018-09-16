package uwt.cloudwatch;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.List;
import java.util.StringTokenizer;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.lambda.AWSLambda;
import com.amazonaws.services.lambda.AWSLambdaClientBuilder;
import com.amazonaws.services.lambda.model.InvokeRequest;
import com.amazonaws.services.lambda.model.InvokeResult;
import com.amazonaws.services.lambda.model.LogType;
import com.amazonaws.services.lambda.model.UpdateFunctionConfigurationRequest;

public class Main {
	private static List<String> data = new ArrayList<String>() ;
	private static final String FUNC_NAME = "test2";
	private static final int LOOPS = 2;

	public static void main(String[] args) {

//		InvokeRequest invokeRequest = new InvokeRequest().withFunctionName("GetWeatherDataFunction")
//				.withPayload("{\n" + " \"city\": \"Paris\",\n" + " \"countryCode\": \"FR\"\n" + "}");
//		BasicAWSCredentials awsCreds = new BasicAWSCredentials("APIADGALD", "PQFNsMOxyrb");
//		AWSLambda awsLambda = AWSLambdaClientBuilder.standard().withRegion(Regions.US_EAST_1)
//				.withCredentials(new AWSStaticCredentialsProvider(awsCreds)).build();

		int[] array = new int[91];
//		array = new int[2]; //test
		Arrays.setAll(array, i -> i * 32 + 128);

		AWSLambda awsLambda = AWSLambdaClientBuilder.standard().withRegion(Regions.US_EAST_1).build();

		for (int mem : array) {
			int x = 0;
			while (x < LOOPS) {
				x++;

				UpdateFunctionConfigurationRequest config = new UpdateFunctionConfigurationRequest()
						.withFunctionName(FUNC_NAME).withMemorySize(mem);
				awsLambda.updateFunctionConfiguration(config);
				InvokeRequest invokeRequest = new InvokeRequest().withFunctionName(FUNC_NAME).withLogType(LogType.Tail);

				InvokeResult invokeResult = null;

				try {
					invokeResult = awsLambda.invoke(invokeRequest);
				} catch (Exception e) {
					System.out.println(e);
				}
//				printInvokeResult(invokeResult);
				saveResult(invokeResult);
			}
		}
		writeToFile();
	}

	private static void saveResult(InvokeResult invokeResult) {
		String log = new String(Base64.getDecoder().decode(invokeResult.getLogResult()),
				Charset.forName("UTF-8"));
		List<String> array = tokenizerArray(log.substring(log.indexOf("Duration")));
		
		// Name,MemorySize,MemoryUsed,Duration,BilledDuration
		String line = String.format("%s,%s,%s,%s,%s", FUNC_NAME, array.get(8), array.get(12), array.get(1), array.get(4));
		System.out.println(line);
		data.add(line);
	}

	private static List<String> tokenizerArray(String str) {
        StringTokenizer st = new StringTokenizer(str, " ");
        List<String> elements = new ArrayList<String>();
 
        while(st.hasMoreTokens()) {
            elements.add(st.nextToken());
        }
        
//        for(String element : elements) {
//            System.out.println(element);
//        }
        return elements;
	}

	private static void writeToFile() {
        Path p = Paths.get("data.csv");
		try (BufferedWriter bw = Files.newBufferedWriter(p, StandardCharsets.US_ASCII, StandardOpenOption.CREATE))
        {
			writeContent(bw);
			bw.close();
        }
        catch (IOException ioe)
        {
            ioe.printStackTrace();
        }
		
	}
	
	private static void writeContent(BufferedWriter bw) throws IOException {
		bw.write("Name,MemorySize,MemoryUsed,Duration,BilledDuration");
		bw.newLine();
		for(String line: data) {
			bw.write(line);
			bw.newLine();
		}
		
	}

	private static void printInvokeResult(InvokeResult invokeResult) {
		System.out.println(invokeResult);
		String log = new String(Base64.getDecoder().decode(invokeResult.getLogResult()),
				Charset.forName("UTF-8"));
		System.out.println(log);
	}
}