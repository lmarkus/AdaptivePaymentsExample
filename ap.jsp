<%--
  PayPal
  Author: Lenny Markus. lmarkus@paypal.com
  Date: 4/22/11
  Time: 5:25 PM
/****************************************************************
THIS IS STRICTLY EXAMPLE SOURCE CODE. IT IS ONLY MEANT TO
QUICKLY DEMONSTRATE THE CONCEPT AND THE USAGE OF THE ADAPTIVE
PAYMENTS API. PLEASE NOTE THAT THIS IS *NOT* PRODUCTION-QUALITY
CODE AND SHOULD NOT BE USED AS SUCH.

THIS EXAMPLE CODE IS PROVIDED TO YOU ONLY ON AN "AS IS"
BASIS WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER
EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY WARRANTIES
OR CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR
FITNESS FOR A PARTICULAR PURPOSE. PAYPAL MAKES NO WARRANTY THAT
THE SOFTWARE OR DOCUMENTATION WILL BE ERROR-FREE. IN NO EVENT
SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL,  EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.
****************************************************************/  
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URLDecoder" %>
<%
out.print("Starting Pay Operation...");
//set PayPal Endpoint to sandbox
String url = "https://svcs.sandbox.paypal.com/AdaptivePayments/Pay";

/*
*******************************************************************
PayPal API Credentials
Replace API_USERNAME with your API Username
Replace API_PASSWORD with your API Password
Replace API_SIGNATURE with your Signature
*******************************************************************
*/

//PayPal API Credentials
    String API_UserName		    = "caller_1303245875_biz_api1.yahoo.com";                       //TODO
    String API_Password		    = "1303245887";                                                 //TODO
    String API_Signature		= "AWGg0IlutB9b.mxXKrxs3FaaUv.nA.ANfIK9qkp06BDMloUHL3JD9ki6";   //TODO

//Default App ID for Sandbox
    String API_AppID			= "APP-80W284485P519543T";

//Request/Response Format
    String API_RequestFormat	= "NV";
    String API_ResponseFormat	= "NV";

//Transaction Parameters
    String receiver			    = "rec1_1303245987_biz@yahoo.com";                              //TODO
    String amount				= "10.00";                                                      //TODO

//Create request payload with minimum required parameters
    String requestBody          =
                                "actionType" 						+"="+ "PAY" +
                                "&currencyCode" 					+"="+ "USD" +
                                "&receiverList.receiver(0).email" 	+"="+ receiver +
                                "&receiverList.receiver(0).amount" 	+"="+ amount +
                                "&returnUrl" 						+"="+ "http://www.example.com/success.html" +
                                "&cancelUrl" 						+"="+ "http://www.example.com/failure.html" +
                                "&requestEnvelope.errorLanguage" 	+"="+ "en_US";


//************************************
//**  Set up HTTP request to PayPal **
//************************************
    out.print("<strong>Done</strong><br>Setting up parameters...");

    URL postURL = new URL( url );
	HttpURLConnection conn = (HttpURLConnection)postURL.openConnection();

	// Set connection parameters. We need to perform input and output,
	// so set both as true.
	conn.setDoInput (true);
	conn.setDoOutput (true);

    // Set Request type
    conn.setRequestMethod("POST");

    // Set request headers
    conn.setRequestProperty("X-PAYPAL-SECURITY-USERID"	    , API_UserName		 );
    conn.setRequestProperty("X-PAYPAL-SECURITY-SIGNATURE"	, API_Signature	     );
    conn.setRequestProperty("X-PAYPAL-SECURITY-PASSWORD"    , API_Password		 );
    conn.setRequestProperty("X-PAYPAL-APPLICATION-ID"		, API_AppID		     );
    conn.setRequestProperty("X-PAYPAL-REQUEST-DATA-FORMAT"	, API_RequestFormat  );
    conn.setRequestProperty("X-PAYPAL-RESPONSE-DATA-FORMAT"	, API_ResponseFormat );


    // Send data to PayPal.
    out.print("<strong>Done</strong><br>Sending information to PayPal...");
    DataOutputStream output = new DataOutputStream( conn.getOutputStream());
    output.write(requestBody.getBytes("UTF-8"));
    output.flush();
    output.close ();

    // Read input from the input stream.
    String payPalresponse = "";
    DataInputStream in = new DataInputStream (conn.getInputStream());
    int rc = conn.getResponseCode();
    if ( rc != -1)
    {
        BufferedReader is = new BufferedReader(new InputStreamReader( conn.getInputStream()));
        String _line = null;
        while(((_line = is.readLine()) !=null))
        {
            payPalresponse += _line;
        }
    }

    //Parse the ap key from the response
    //Display the Paypal response
    out.print("<strong>Done</strong><br><br>Response from PayPal: <br><br>");
    HashMap<String,String> responseParameters = new HashMap<String, String>();
	String[] responseParts = payPalresponse.split("&");
    for(String part: responseParts){
        String[] nameValue = part.split("=");
        responseParameters.put(nameValue[0],URLDecoder.decode(nameValue[1],"UTF-8"));
        out.print(nameValue[0]+" = <b>"+URLDecoder.decode(nameValue[1],"UTF-8")+"</b><br>");
    }
    out.print("<br>");


//************************************
//**  Analyze response and redirect **
//**        user to PayPal          **
//************************************

    //Check to see if the request was sucessful.
    if (responseParameters.get("responseEnvelope.ack").equalsIgnoreCase("Success")){

        //Set url to approve the transaction
        String payPalURL = "https://www.sandbox.paypal.com/webscr?cmd=_ap-payment&paykey=" + responseParameters.get("payKey");

        //The user must be sent to paypal to approve the transaction. This redirection is tipically done
		//automatically. But for testing purposes, we will display the URL, as a link. It must be clicked by hand.
		//If you would like to redirect the user to PayPal automatically, simply uncomment the following block
	     /*
	    response.sendRedirect(payPalURL);
	    if(true) {return};
	     */

		out.println("Transaction Created. Click below to redirect to PayPal so that payment can be approved.<br><a href='" + payPalURL +"' target='_blank'>" + payPalURL + "</a>");
	}
	else {
		out.println("ERROR Code:   " +  responseParameters.get("error(0).errorId") + " <br/>");
		out.println("ERROR Message:" +  responseParameters.get("error(0).message") + " <br/>");
	}


%>