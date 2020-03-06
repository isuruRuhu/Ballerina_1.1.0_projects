import ballerina/http;
import ballerina/log;
import ballerinax/java.jdbc;

listener http:Listener httpListener = new(9090);

type Employee record {
    string name;
    int age;
    int ssn;
};

jdbc:Client employeeDB = new({
    url: "jdbc:mysql://localhost:3306/EMPLOYEE_RECORDS",
    username: "root",
    password: "root",
    poolOptions: { maximumPoolSize: 500 },
    dbOptions: { useSSL: false }
});

// Service for the employee data service
@http:ServiceConfig {
    basePath: "/records"
}
service EmployeeData on httpListener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/employee/"
    }
    resource function addEmployeeResource(http:Caller httpCaller, http:Request request) {
        // Initialize an empty http response message
        http:Response response = new;

        // Extract the data from the request payload
        var payloadJson = request.getJsonPayload();


        if (payloadJson is json) {
            Employee|error employeeData = Employee.constructFrom(payloadJson);
            //Employee|error employeeData = Employee.convert(payloadJson);

            if (employeeData is Employee) {
                // Validate JSON payload
                if (employeeData.name == "" || employeeData.age == 0 || employeeData.ssn == 0) {
                    response.setPayload("Error : json payload should contain{name:<string>, age:<int>, ssn:<123456>}");
                    response.statusCode = 400;
                } else {
                    // Invoke insertData function to save data in the MySQL database
                    json ret = insertData(httpCaller, employeeData.name, employeeData.age, employeeData.ssn);
                    // Send the response back to the client with the employee data
                    response.setPayload(ret);
                }
            } else {
                // Send an error response in case of a conversion failure
                response.statusCode = 400;
                response.setPayload("Error: Please send the JSON payload in the correct format");
            }
        } else {
            // Send an error response in case of an error in retriving the request payload
            response.statusCode = 500;
            response.setPayload("Error: An internal error occurred");
        }
        var respondRet = httpCaller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            log:printError("Error responding to the client");
        }
        //var result = httpCaller->respond("data_instereted");
    }
}

public function insertData(http:Caller caller, string name, int age, int ssn) returns (json) {
    json updateStatus;
    string sqlString = "INSERT INTO EMPLOYEES (Name, Age, SSN) VALUES (?,?,?)";
    // Insert data to SQL database by invoking update action
    var ret = employeeDB->update(sqlString, name, age, ssn);

    //var ret = employeeDB->update("INSERT INTO EMPLOYEES(name, age, ssn) " + "values (" + name + "," + age + "," + ssn +")");

    //if (ret is jdbc:UpdateResult) {
    //    io:println("Inserted row count to Students table: ", ret.updatedRowCount);
    //} else {
    //    error err = ret;
    //    io:println("Insert to Students table failed: ", <string>err.detail()["message"]);
    //}

    return;
}