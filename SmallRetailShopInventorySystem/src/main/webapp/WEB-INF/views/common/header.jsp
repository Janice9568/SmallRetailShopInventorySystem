<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RetailPOS | Inventory System</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <!-- Custom Style -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        body { background-color: #f8f9fa; min-height: 100vh; display: flex; flex-direction: column; }
        .navbar-brand { font-weight: bold; }
        .low-stock-alert { background-color: #f8d7da !important; }
        main { flex: 1; padding-bottom: 3rem; }
        .dropdown-item i { margin-right: 10px; width: 20px; text-align: center; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-shop"></i> RetailPOS
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/dashboard">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                </li>

                <%-- FR4 & FR5: Cashier and Owner only --%>
                <c:if test="${currentUser.role == 'CASHIER' || currentUser.role == 'OWNER'}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="salesDrop" data-bs-toggle="dropdown">
                            <i class="bi bi-cart-check"></i> Sales
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/sales?action=pos"><i class="bi bi-plus-circle"></i> New Sale (POS)</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/sales?action=history"><i class="bi bi-clock-history"></i> Sales History</a></li>
                        </ul>
                    </li>
                </c:if>

                <%-- FR2 & FR3: Inventory Staff and Owner only --%>
                <c:if test="${currentUser.role == 'INVENTORY_STAFF' || currentUser.role == 'OWNER'}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="invDrop" data-bs-toggle="dropdown">
                            <i class="bi bi-box-seam"></i> Inventory
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products"><i class="bi bi-list-ul"></i> Product List</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/inventory"><i class="bi bi-arrow-repeat"></i> Update Stock</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports?action=lowStock"><i class="bi bi-exclamation-triangle"></i> Low Stock Report</a></li>
                        </ul>
                    </li>
                </c:if>

                <%-- FR6 & FR7: Owner Tools Only --%>
                <c:if test="${currentUser.role == 'OWNER'}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="ownerDrop" data-bs-toggle="dropdown">
                            <i class="bi bi-shield-lock"></i> Owner Tools
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports?action=salesSummary"><i class="bi bi-graph-up"></i> Financial Reports</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports?action=performance"><i class="bi bi-star"></i> Product Performance</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/suppliers"><i class="bi bi-truck"></i> Suppliers</a></li>
                        </ul>
                    </li>
                </c:if>
            </ul>

            <%-- User Profile & Session --%>
            <div class="d-flex align-items-center">
                <c:if test="${not empty currentUser}">
                    <div class="dropdown">
                        <button class="btn btn-outline-light dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-person-circle"></i> ${currentUser.fullName}
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><span class="dropdown-item-text text-muted">Role: <strong>${currentUser.role}</strong></span></li>
                            <li><hr class="dropdown-divider"></li>
                            <li>
                                <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                                    <i class="bi bi-box-arrow-right"></i> Logout
                                </a>
                            </li>
                        </ul>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</nav>

<main class="container">
<%-- Content from specific JSPs starts here --%>