<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp" />

<div class="row justify-content-center">
    <div class="col-md-5">
        <div class="card shadow">
            <div class="card-header bg-primary text-white">Update Payment Info</div>
            <div class="card-body">
                <form action="payments" method="post">
                    <input type="hidden" name="saleId" value="${param.saleId}">
                    <div class="mb-3">
                        <label class="form-label">Transaction ID</label>
                        <input type="text" class="form-control" value="#SAL-${param.saleId}" disabled>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Payment Status</label>
                        <select name="paymentStatus" class="form-select">
                            <option value="PAID">PAID</option>
                            <option value="UNPAID">UNPAID</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Payment Method</label>
                        <select name="paymentMethod" class="form-select">
                            <option value="CASH">Cash</option>
                            <option value="CREDIT_CARD">Credit Card</option>
                            <option value="E-WALLET">E-Wallet</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-success w-100">Save Changes</button>
                    <a href="sales?action=history" class="btn btn-link w-100 mt-2">Back to History</a>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />