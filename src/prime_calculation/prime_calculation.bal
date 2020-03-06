import ballerina/log;
import ballerina/http;

service hello on new http:Listener(9090) {

    resource function sayHello(http:Caller caller, http:Request req) {

        byte[]|error payload = req.getBinaryPayload();

        if(payload is byte[]){
            int n=7019;

            checkPrime(n);
            var result = caller->respond("7019!");
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        }
    }
}

public function checkPrime(int n) {
    int i=2;
    int m=0;
    int flag=0;

    m=n/2;
    if(n==0||n==1){
        log:printInfo("is not prime number");
    }else{
        while(i<=m){
            if(n%i==0){
                log:printInfo("is not prime number");
                flag=1;
                break;
            }
            i=i+1;
        }
        if(flag==0)  {
            log:printInfo("is a prime number");
        }
    }
}