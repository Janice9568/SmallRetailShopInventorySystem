<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="../common/header.jsp" />

<div class="container my-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-dark mb-1">Analytics Dashboard</h2>
            <p class="text-secondary mb-0">Monitor sales performance, item analytics, and stock health.</p>
        </div>
    </div>

    <div class="card shadow-sm mb-4">
        <div class="card-header bg-white fw-bold d-flex justify-content-between align-items-center py-3">
            <span><i class="bi bi-filter-left fs-5 me-2"></i>Filter Report Date Range</span>
            <button type="button" onclick="selectTodayAndSubmit()" class="btn btn-sm btn-outline-primary fw-bold px-3">
                <i class="bi bi-clock-history me-1"></i> Today
            </button>
        </div>
        <div class="card-body p-4">
            <form action="${pageContext.request.contextPath}/reports" method="get" id="reportFilterForm">
                <input type="hidden" name="action" value="printReport">

                <div class="row align-items-end">
                    <div class="col-md-4 mb-3 mb-md-0">
                        <label class="form-label small fw-bold text-secondary">Start Date</label>
                        <input type="date" id="filterStartDate" name="startDate" class="form-control form-control-lg" required>
                    </div>
                    <div class="col-md-4 mb-3 mb-md-0">
                        <label class="form-label small fw-bold text-secondary">End Date</label>
                        <input type="date" id="filterEndDate" name="endDate" class="form-control form-control-lg" required>
                    </div>
                    <div class="col-md-4">
                        <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold shadow-sm">
                            <i class="bi bi-file-earmark-bar-graph me-2"></i>Generate Report
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-7">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-white fw-bold py-3">
                    <i class="bi bi-graph-up-arrow me-2 text-primary"></i>Daily Sales Summary
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Date</th>
                                <th class="text-end">Revenue Total</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="entry" items="${salesData}">
                                <tr>
                                    <td class="fw-medium text-secondary">${entry.key}</td>
                                    <td class="text-end fw-bold text-dark">
                                        RM <fmt:formatNumber value="${entry.value}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty salesData}">
                                <tr>
                                    <td colspan="2" class="text-center text-muted py-4">No data logged for this timeframe.</td>
                                </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-5">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-white fw-bold py-3">
                    <i class="bi bi-trophy me-2 text-warning"></i>Top 10 Best Selling Items
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Product Item Name</th>
                                <th class="text-center" width="100">Units Sold</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="entry" items="${performanceData}">
                                <tr>
                                    <td class="fw-medium text-dark">${entry.key}</td>
                                    <td class="text-center fw-bold text-primary">
                                        <span class="badge bg-primary-subtle text-primary rounded-pill px-3">${entry.value}</span>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty performanceData}">
                                <tr>
                                    <td colspan="2" class="text-center text-muted py-4">No item metrics captured yet.</td>
                                </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 mt-4">
            <div class="card shadow-sm border-danger-subtle">
                <div class="card-header bg-danger-subtle text-danger fw-bold py-3">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>Critical Inventory Alert (Low Stock)
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th class="ps-4">Product Name</th>
                                <th class="text-center" width="180">Current Stock</th>
                                <th class="text-center" width="180">Low Stock Threshold</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="prod" items="${lowStockList}">
                                <tr>
                                    <td class="fw-bold text-dark ps-4">${prod.productName}</td>
                                    <td class="text-center">
                                            <span class="badge ${prod.stockQuantity == 0 ? 'bg-danger' : 'bg-warning text-dark'} fw-bold px-3 py-1fs-6">
                                                    ${prod.stockQuantity}
                                            </span>
                                    </td>
                                    <td class="text-center text-secondary fw-medium">${prod.lowStockThreshold}</td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty lowStockList}">
                                <tr>
                                    <td colspan="3" class="text-center text-success fw-medium py-4">
                                        <i class="bi bi-check-circle-fill me-2"></i>All product inventories are perfectly healthy!
                                    </td>
                                </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function selectTodayAndSubmit() {
        const today = new Date();
        const year = today.getFullYear();
        // 补齐 0 位，确保长得像 "05" 或者 "17"
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        const formattedDate = `${year}-${month}-${day}`;

        // 自动赋入今日日期值
        document.getElementById('filterStartDate').value = formattedDate;
        document.getElementById('filterEndDate').value = formattedDate;

        // 啪的一声，自动提交流水表单
        document.getElementById('reportFilterForm').submit();
    }
</script>

<jsp:include page="../common/footer.jsp" />