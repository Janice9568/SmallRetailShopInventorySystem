<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp" />

<div class="row">
    <!-- Product Selection -->
    <div class="col-md-4">
        <div class="card shadow-sm mb-4">
            <div class="card-header bg-dark text-white">Select Products</div>
            <div class="card-body">
                <div class="mb-3">
                    <label class="form-label">Search Product</label>
                    <select id="productPicker" class="form-select">
                        <option value="">-- Choose a Product --</option>
                        <c:forEach var="p" items="${products}">
                            <option value="${p.productId}"
                                    data-name="${p.productName}"
                                    data-price="${p.price}"
                                    data-stock="${p.stockQuantity}">
                                    ${p.productName} (Stock: ${p.stockQuantity})
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <button type="button" onclick="addToCart()" class="btn btn-primary w-100">
                    <i class="bi bi-plus-lg"></i> Add to Cart
                </button>
            </div>
        </div>
    </div>

    <!-- Cart / Transaction Details -->
    <div class="col-md-8">
        <form action="${pageContext.request.contextPath}/sales" method="post">
            <div class="card shadow-sm">
                <div class="card-header bg-white">
                    <h5 class="mb-0">Current Transaction</h5>
                </div>
                <div class="card-body">
                    <table class="table table-bordered" id="cartTable">
                        <thead class="table-light">
                        <tr>
                            <th>Product</th>
                            <th width="100">Price</th>
                            <th width="100">Qty</th>
                            <th width="120">Subtotal</th>
                            <th width="50"></th>
                        </tr>
                        </thead>
                        <tbody>
                        <!-- Dynamic Rows -->
                        </tbody>
                        <tfoot>
                        <tr>
                            <th colspan="3" class="text-end">Total Amount:</th>
                            <th id="grandTotalText">$0.00</th>
                        </tr>
                        </tfoot>
                    </table>

                    <div class="row mt-4">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Payment Method</label>
                            <select name="paymentMethod" class="form-select" required>
                                <option value="CASH">Cash</option>
                                <option value="CREDIT_CARD">Credit Card</option>
                                <option value="E-WALLET">E-Wallet</option>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Payment Status</label>
                            <select name="paymentStatus" class="form-select" required>
                                <option value="PAID">Paid</option>
                                <option value="UNPAID">Unpaid</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="card-footer text-end">
                    <button type="submit" class="btn btn-success btn-lg">
                        <i class="bi bi-check-circle"></i> Confirm Sale
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    function addToCart() {
        const picker = document.getElementById('productPicker');
        const selected = picker.options[picker.selectedIndex];

        if (!selected.value) return;

        const id = selected.value;
        const name = selected.getAttribute('data-name');
        const price = parseFloat(selected.getAttribute('data-price'));
        const stock = parseInt(selected.getAttribute('data-stock'));

        // Check if product already in cart
        const existingRow = document.querySelector(`tr[data-id="${id}"]`);
        if (existingRow) {
            const qtyInput = existingRow.querySelector('.qty-input');
            if (parseInt(qtyInput.value) < stock) {
                qtyInput.value = parseInt(qtyInput.value) + 1;
                updateRowTotal(qtyInput);
            } else {
                alert('Insufficient stock!');
            }
            return;
        }

        if (stock <= 0) {
            alert('Product out of stock!');
            return;
        }

        const tbody = document.querySelector('#cartTable tbody');
        const row = document.createElement('tr');
        row.setAttribute('data-id', id);
        row.innerHTML = `
        <td>
            ${name}
            <input type="hidden" name="productId[]" value="${id}">
        </td>
        <td>$${price.toFixed(2)}</td>
        <td>
            <input type="number" name="qty[]" class="form-control form-control-sm qty-input"
                   value="1" min="1" max="${stock}" onchange="updateRowTotal(this)">
        </td>
        <td class="row-total" data-price="${price}">$${price.toFixed(2)}</td>
        <td>
            <button type="button" class="btn btn-sm btn-danger" onclick="this.closest('tr').remove(); calculateGrandTotal();">
                <i class="bi bi-x"></i>
            </button>
        </td>
    `;
        tbody.appendChild(row);
        calculateGrandTotal();
    }

    function updateRowTotal(input) {
        const row = input.closest('tr');
        const price = parseFloat(row.querySelector('.row-total').getAttribute('data-price'));
        const qty = parseInt(input.value);
        const subtotal = price * qty;
        row.querySelector('.row-total').innerText = '$' + subtotal.toFixed(2);
        calculateGrandTotal();
    }

    function calculateGrandTotal() {
        let total = 0;
        document.querySelectorAll('.row-total').forEach(cell => {
            total += parseFloat(cell.innerText.replace('$', ''));
        });
        document.getElementById('grandTotalText').innerText = '$' + total.toFixed(2);
    }
</script>

<jsp:include page="../common/footer.jsp" />