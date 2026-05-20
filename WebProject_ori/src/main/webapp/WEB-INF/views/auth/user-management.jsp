<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp" />

<div class="row">
    <div class="col-md-4">
        <div class="card shadow-sm">
            <div class="card-header bg-primary text-white">Register New Staff</div>
            <div class="card-body">
                <form action="users" method="post">
                    <div class="mb-3"><label>Full Name</label><input type="text" name="fullName" class="form-control" required></div>
                    <div class="mb-3"><label>Username</label><input type="text" name="username" class="form-control" required></div>
                    <div class="mb-3"><label>Password</label><input type="password" name="password" class="form-control" required></div>
                    <div class="mb-3">
                        <label>Role</label>
                        <select name="role" class="form-select">
                            <option value="CASHIER">Cashier Staff</option>
                            <option value="INVENTORY_STAFF">Inventory Staff</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Add Staff Member</button>
                </form>
            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="card shadow-sm">
            <div class="card-header bg-white">Current Staff List</div>
            <div class="card-body">
                <table class="table">
                    <thead><tr><th>Name</th><th>Username</th><th>Role</th><th>Action</th></tr></thead>
                    <tbody>
                    <c:forEach var="u" items="${staffList}">
                        <tr>
                            <td>${u.fullName}</td><td>${u.username}</td>
                            <td><span class="badge bg-info">${u.role}</span></td>
                            <td><a href="users?action=delete&id=${u.userId}" class="btn btn-sm btn-danger" onclick="return confirm('Delete user?')">Remove</a></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<jsp:include page="../common/footer.jsp" />