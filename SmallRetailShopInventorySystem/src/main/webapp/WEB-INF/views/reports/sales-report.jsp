<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp" />

<div class="row mb-4">
    <div class="col-12">
        <div class="card shadow-sm">
            <div class="card-header bg-white">
                <h5 class="mb-0">Filter Report Date Range</h5>
            </div>
            <div class="card-body">
                <form class="row g-3" method="get" action="reports">
                    <div class="col-md-4">
                        <label class="form-label">Start Date</label>
                        <input type="date" name="startDate" class="form-control" value="${startDate}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">End Date</label>
                        <input type="date" name="endDate" class="form-control" value="${endDate}">
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">Generate Report</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <!-- Sales Summary Table -->
    <div class="col-md-6 mb-4">
        <div class="card shadow-sm h-100">
            <div class="card-header bg-success text-white">Daily Sales Summary</div>
            <div class="card-body">
                <table class="table">
                    <thead>
                    <tr><th>Date</th><th class="text-end">Revenue</th></tr>
                    </thead>
                    <tbody>
                    <c:forEach var="entry" items="${salesData}">
                        <tr>
                            <td>${entry.key}</td>
                            <td class="text-end"><fmt:formatNumber value="${entry.value}" type="currency" /></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Best Sellers -->
    <div class="col-md-6 mb-4">
        <div class="card shadow-sm h-100">
            <div class="card-header bg-info text-white">Top 10 Best Selling Items</div>
            <div class="card-body">
                <table class="table">
                    <thead>
                    <tr><th>Product Name</th><th class="text-center">Units Sold</th></tr>
                    </thead>
                    <tbody>
                    <c:forEach var="entry" items="${performanceData}">
                        <tr>
                            <td>${entry.key}</td>
                            <td class="text-center"><span class="badge bg-secondary">${entry.value}</span></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <!-- Low Stock Reports FR6.4 -->
    <div class="col-12">
        <div class="card shadow-sm border-danger">
            <div class="card-header bg-danger text-white">Critical Inventory Alert (Low Stock)</div>
            <div class="card-body">
                <table class="table table-sm">
                    <thead>
                    <tr>
                        <th>Product</th><th>Current Stock</th><th>Threshold</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="p" items="${lowStockList}">
                        <tr>
                            <td>${p.productName}</td>
                            <td class="text-danger fw-bold">${p.stockQuantity}</td>
                            <td>${p.lowStockThreshold}</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />