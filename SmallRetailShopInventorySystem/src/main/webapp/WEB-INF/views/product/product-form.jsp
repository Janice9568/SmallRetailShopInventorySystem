<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp" />

<div class="row justify-content-center">
    <div class="col-md-8">
        <div class="card shadow">
            <div class="card-header bg-primary text-white">
                <h4 class="mb-0">
                    <c:choose>
                        <c:when test="${product != null}">Edit Product</c:when>
                        <c:otherwise>Add New Product</c:otherwise>
                    </c:choose>
                </h4>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/products" method="post" class="needs-validation" novalidate>
                    <c:if test="${product != null}">
                        <input type="hidden" name="productId" value="${product.productId}">
                    </c:if>

                    <div class="mb-3">
                        <label for="productName" class="form-label">Product Name</label>
                        <input type="text" class="form-control" id="productName" name="productName"
                               value="${product.productName}" required>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="categoryId" class="form-label">Category</label>
                            <select class="form-select" name="categoryId" id="categoryId" required>
                                <option value="1" ${product.categoryId == 1 ? 'selected' : ''}>Electronics</option>
                                <option value="2" ${product.categoryId == 2 ? 'selected' : ''}>Groceries</option>
                                <option value="3" ${product.categoryId == 3 ? 'selected' : ''}>Stationery</option>
                                <option value="4" ${product.categoryId == 4 ? 'selected' : ''}>Apparel</option>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="model" class="form-label">Model/Brand</label>
                            <input type="text" class="form-control" id="model" name="model" value="${product.model}">
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="price" class="form-label">Price ($)</label>
                            <input type="number" step="0.01" class="form-control" id="price" name="price"
                                   value="${product.price}" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="supplierId" class="form-label">Supplier</label>
                            <select class="form-select" name="supplierId" id="supplierId" required>
                                <c:forEach var="sup" items="${suppliers}">
                                    <option value="${sup.supplierId}" ${product.supplierId == sup.supplierId ? 'selected' : ''}>
                                            ${sup.supplierName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="stockQuantity" class="form-label">Initial Stock Quantity</label>
                            <input type="number" class="form-control" id="stockQuantity" name="stockQuantity"
                                   value="${product.stockQuantity}" ${product != null ? 'readonly' : ''} required>
                            <c:if test="${product != null}">
                                <small class="text-muted">Use Inventory Management to update existing stock.</small>
                            </c:if>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="lowStockThreshold" class="form-label">Low Stock Alert Level</label>
                            <input type="number" class="form-control" id="lowStockThreshold" name="lowStockThreshold"
                                   value="${product.lowStockThreshold != null ? product.lowStockThreshold : 10}" required>
                        </div>
                    </div>

                    <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                        <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary me-md-2">Cancel</a>
                        <button type="submit" class="btn btn-success">Save Product</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />