<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3><i class="bi bi-truck"></i> Supplier Management</h3>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addSupplierModal">
        <i class="bi bi-plus-circle"></i> Add New Supplier
    </button>
</div>

<div class="card shadow-sm">
    <div class="card-body">
        <table class="table table-striped">
            <thead>
            <tr>
                <th>Supplier Name</th>
                <th>Contact Person</th>
                <th>Phone</th>
                <th>Email</th>
                <th>Address</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="s" items="${supplierList}">
                <tr>
                    <td><strong>${s.supplierName}</strong></td>
                    <td>${s.contactPerson}</td>
                    <td>${s.phone}</td>
                    <td>${s.email}</td>
                    <td>${s.address}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<!-- Add Supplier Modal -->
<div class="modal fade" id="addSupplierModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="suppliers" method="post">
                <div class="modal-header">
                    <h5 class="modal-title">New Supplier Info</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Supplier Name</label>
                        <input type="text" name="supplierName" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Contact Person</label>
                        <input type="text" name="contactPerson" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Phone</label>
                        <input type="text" name="phone" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Address</label>
                        <textarea name="address" class="form-control"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary">Save Supplier</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />