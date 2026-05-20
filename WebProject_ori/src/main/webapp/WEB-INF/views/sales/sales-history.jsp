<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp" />

<div class="card shadow-sm">
    <div class="card-header bg-white d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Sales Transaction History</h5>
    </div>
    <div class="card-body">
        <c:set var="totalCount" value="0" />
        <c:set var="grandTotalAmount" value="0" />

        <table class="table table-hover align-middle">
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
                <c:set var="totalCount" value="${totalCount + 1}" />
                <c:set var="grandTotalAmount" value="${grandTotalAmount + sale.totalAmount}" />

                <tr>
                    <td><fmt:formatDate value="${sale.saleDate}" pattern="yyyy-MM-dd HH:mm" /></td>
                    <td>#SAL-${sale.saleId}</td>
                    <td>${sale.sellerName}</td>
                    <td class="fw-bold text-dark">RM <fmt:formatNumber value="${sale.totalAmount}" type="number" minFractionDigits="2" maxFractionDigits="2"/></td>
                    <td>${sale.paymentMethod}</td>
                    <td>
                        <span class="badge ${sale.paymentStatus == 'PAID' ? 'bg-success' : 'bg-danger'}">
                                ${sale.paymentStatus}
                        </span>
                    </td>
                    <td>
                        <div class="btn-group">
                            <a href="${pageContext.request.contextPath}/payments?saleId=${sale.saleId}" class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-pencil"></i> Update
                            </a>
                            <a href="${pageContext.request.contextPath}/sales?action=delete&saleId=${sale.saleId}"
                               class="btn btn-sm btn-outline-danger"
                               onclick="return confirm('Are you sure you want to DELETE this transaction? This action cannot be undone.');">
                                <i class="bi bi-trash"></i> Delete
                            </a>
                        </div>
                    </td>
                </tr>
            </c:forEach>
            </tbody>

            <tfoot class="table-light border-top-2">
            <tr class="fs-6 fw-bold">
                <td colspan="3" class="text-end text-secondary">Total Transactions:</td>
                <td class="text-primary">${totalCount} Orders</td>
                <td class="text-end text-secondary">Grand Total:</td>
                <td colspan="2" class="text-success fs-5">
                    RM <fmt:formatNumber value="${grandTotalAmount}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />