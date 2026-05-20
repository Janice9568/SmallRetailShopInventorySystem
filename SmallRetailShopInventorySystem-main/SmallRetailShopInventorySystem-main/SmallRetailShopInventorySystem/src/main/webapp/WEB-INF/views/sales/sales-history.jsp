<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp" />

<div class="card shadow-sm">
    <div class="card-header bg-white d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Sales Transaction History</h5>
    </div>
    <div class="card-body">
        <table class="table table-hover">
            <thead>
            <tr>
                <th>Date</th>
                <th>Transaction ID</th>
                <th>Cashier</th>
                <th>Total</th>
                <th>Method</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="sale" items="${salesList}">
                <tr>
                    <td><fmt:formatDate value="${sale.saleDate}" pattern="yyyy-MM-dd HH:mm" /></td>
                    <td>#SAL-${sale.saleId}</td>
                    <td>${sale.sellerName}</td>
                    <td><fmt:formatNumber value="${sale.totalAmount}" type="currency" /></td>
                    <td>${sale.paymentMethod}</td>
                    <td>
                            <span class="badge ${sale.paymentStatus == 'PAID' ? 'bg-success' : 'bg-danger'}">
                                    ${sale.paymentStatus}
                            </span>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/payments?saleId=${sale.saleId}" class="btn btn-sm btn-outline-primary">
                            Update Payment
                        </a>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />