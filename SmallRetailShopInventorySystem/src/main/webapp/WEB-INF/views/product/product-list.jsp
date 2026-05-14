<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3><i class="bi bi-list-ul"></i> Product Inventory</h3>
    <c:if test="${currentUser.role == 'OWNER'}">
        <a href="${pageContext.request.contextPath}/products?action=new" class="btn btn-primary">
            <i class="bi bi-plus-circle"></i> Add New Product
        </a>
    </c:if>
</div>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead class="table-light">
                <tr>
                    <th>ID</th>
                    <th>Product Name</th>
                    <th>Category</th>
                    <th>Model</th>
                    <th>Supplier</th>
                    <th class="text-end">Price</th>
                    <th class="text-center">Stock</th>
                    <c:if test="${currentUser.role == 'OWNER'}">
                        <th class="text-center">Actions</th>
                    </c:if>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="product" items="${productList}">
                    <tr class="${product.stockQuantity <= product.lowStockThreshold ? 'low-stock-alert' : ''}">
                        <td>${product.productId}</td>
                        <td>
                            <strong>${product.productName}</strong>
                            <c:if test="${product.stockQuantity <= product.lowStockThreshold}">
                                <span class="badge bg-danger ms-1">Low Stock</span>
                            </c:if>
                        </td>
                        <td>${product.categoryName}</td>
                        <td>${product.model}</td>
                        <td>${product.supplierName}</td>
                        <td class="text-end">
                            <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="$" />
                        </td>
                        <td class="text-center">
                            <span class="fw-bold">${product.stockQuantity}</span>
                        </td>
                        <c:if test="${currentUser.role == 'OWNER'}">
                            <td class="text-center">
                                <div class="btn-group btn-group-sm">
                                    <a href="${pageContext.request.contextPath}/products?action=edit&id=${product.productId}"
                                       class="btn btn-outline-primary" title="Edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/products?action=delete&id=${product.productId}"
                                       class="btn btn-outline-danger"
                                       onclick="return confirm('Are you sure you want to remove this product?')" title="Delete">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
                <c:if test="${empty productList}">
                    <tr>
                        <td colspan="8" class="text-center py-4 text-muted">No products found in inventory.</td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />