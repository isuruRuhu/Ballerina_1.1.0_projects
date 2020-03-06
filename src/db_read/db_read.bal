import ballerina/lang.'int as ints;
import ballerina/http;
import ballerinax/java.jdbc;
import ballerina/log;
import ballerina/jsonutils;


listener http:Listener httpListener = new(9090);

type Employee record {
    string name;
    int age;
    int ssn;
};

jdbc:Client employeeDB = new({
    url: "jdbc:mysql://localhost:3306/EMPLOYEE_RECORDS",
    username: "root",
    password: "root1234",
    poolOptions: {maximumPoolSize: 500},
    dbOptions: { useSSL: false }
    });


// Service for the employee data service
@http:ServiceConfig {
    basePath: "/records"
}
service EmployeeData on httpListener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/employee/{employeeId}"
    }
    resource function retrieveEmployeeResource(http:Caller httpCaller, http:Request request, string
        employeeId) {
        // Initialize an empty http response message
        http:Response response = new;
        // Convert the employeeId string to integer
        //var empID = int.convert(employeeId);
        //var empID = 'int.valueOf(employeeId);
        int|error empID = ints:fromString(employeeId);
        if (empID is int) {
        //    // Invoke retrieveById function to retrieve data from Mymysql database
            var employeeData = retrieveById(empID);
        //    // Send the response back to the client with the employee data
            response.setPayload(employeeData);
        } else {
            response.statusCode = 400;
            response.setPayload("Error: employeeId parameter should be a valid integer");
        }
        var respondRet = httpCaller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            log:printError("Error responding to the client", err = respondRet);
        }
    }
}


public function retrieveById(int employeeID) returns (json) {
    json jsonReturnValue = {};
    string sqlString = "SELECT * FROM EMPLOYEES WHERE EmployeeID = ?";
    // Retrieve employee data by invoking select remote function defined in ballerina sql client
    var ret = employeeDB->select(sqlString, (), employeeID);
    if (ret is table<record {}>) {
        // Convert the sql data table into JSON using type conversion
        //var jsonConvertRet = json.convert(ret);
        json|error jsonConvertRet = jsonutils:fromTable(ret);
        //var jsonConvertRet = ret.toJsonString();
        if (jsonConvertRet is json) {
            jsonReturnValue = jsonConvertRet;
        } else {
            jsonReturnValue = { "Status": "Data Not Found", "Error": "Error occurred in data conversion" };
            log:printError("Error occurred in data conversion");
        }
    } else {
        jsonReturnValue = { "Status": "Data Not Found", "Error": "Error occurred in data retrieval" };
        log:printError("Error occurred in data retrieval", err = ret);
    }
    return jsonReturnValue;
}