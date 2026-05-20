<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp" />

<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card shadow">
            <div class="card-header bg-dark text-white">Manual Stock Adjustment</div>
            <div class="card-body">
                <form action="inventory" method="post">
                    <div class="mb-3">
                        <label class="form-label">Select Product</label>
                        <select name="productId" class="form-select" required>
                            <c:forEach var="p" items="${productList}">
                                <option value="${p.productId}">${p.productName} (Current: ${p.stockQuantity})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Adjustment Quantity</label>
                        <input type="number" name="changeQty" class="form-control" placeholder="e.g. 50 to add, -10 to remove" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Reason for Adjustment</label>
                        <input type="text" name="reason" class="form-control" placeholder="Restock, Damage, Return, etc." required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Record Adjustment</button>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />