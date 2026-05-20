<%--
  Created by IntelliJ IDEA.
  User: Home Use PC
  Date: 17-May-26
  Time: 11:09 PM
  To change this template use File | Settings | File Templates.

  JSP SCRIPTLETS!!!!
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    final double price = 10.0;

    String code = request.getParameter("customerCode");
    String custType = request.getParameter("customerType");

    int quantity = 0;
    try{
        quantity = Integer.parseInt(request.getParameter("quantity"));
    }catch(Exception e){
        quantity = 0;
    }

    double total = 0;
    String message = "";

    if(custType.equals("1") && quantity > 100){
        message = "You're entitled to 10% discount";
        total = quantity * price * 0.9;
    }else if(custType.equals("2") && quantity > 100){
        message = "You're entitled to 25% discount";
        total = quantity * price * 0.75;
    }else{
        message = "You're not entitled to any discount";
        total = quantity * price;
    }

    String custTypeDisplay = custType.equals("1")? "Normal Customer" : "Privilege Customer";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Processing Result</title>
    <link href="style.css" rel="stylesheet">
</head>
<body>
<div>
    <h1>Transaction Summary</h1>

    <div>
        <div>
            <label>Customer Code:</label>
            <p><%= code%></p>
        </div>

        <div>
            <label>Quantity:</label>
            <p><%= quantity%></p>
        </div>

        <div>
            <label>Customer Type:</label>
            <p><%= custTypeDisplay%></p>
        </div>

        <div>
            <label>Status:</label>
            <p><%= message%></p>
        </div>

        <div>
            <label>Total Amount:</label>
            <p>RM<%=total%></p>
        </div>

    </div>
</div>
</body>