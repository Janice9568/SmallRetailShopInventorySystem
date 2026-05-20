<%--
  Created by IntelliJ IDEA.
  User: 60179
  Date: 17/5/2026
  Time: 10:12 pm
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
  <title>Daily Sales Report</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body { background-color: #fcfcfd; font-family: 'Segoe UI', system-ui, sans-serif; padding: 20px; }
    .report-wrapper { max-width: 900px; margin: 20px auto; background: white; padding: 30px; }

    .report-title { font-size: 24px; font-weight: 800; color: #111; margin-bottom: 5px; }
    .report-date { font-size: 15px; color: #666; margin-bottom: 25px; }

    /* 1:1 还原截图上的梦幻渐变紫表头 */
    .purple-header {
      background: linear-gradient(90deg, #5c6bc0 0%, #7e57c2 100%) !important;
      color: white !important;
      font-weight: 600;
      border: none !important;
    }

    .table { border-collapse: separate; border-spacing: 0; }
    .table th, .table td { padding: 14px 18px; border-bottom: 1px solid #edf2f7; }

    /* 截图下方的蓝色高亮汇总栏 */
    .total-summary-row {
      background-color: #f0f4ff !important;
      font-weight: bold;
      font-size: 16px;
    }

    /* 1:1 还原精美紫色圆角按钮样式 */
    .btn-purple {
      background: linear-gradient(135deg, #5c6bc0 0%, #7e57c2 100%);
      color: white;
      border: none;
      padding: 10px 24px;
      font-weight: 600;
      border-radius: 8px;
      transition: all 0.2s;
      text-decoration: none;
      display: inline-block;
    }
    .btn-purple:hover { background: linear-gradient(135deg, #4e5dbc 0%, #6f48b7 100%); color: white; box-shadow: 0 4px 12px rgba(111,72,183,0.3); }

    @media print {
      .no-print { display: none !important; }
      .report-wrapper { padding: 0; margin: 0; max-width: 100%; }
      body { background: white; padding: 0; }
    }
  </style>
</head>
<body>

<div class="report-wrapper">
  <div class="report-title">Daily Sales Report</div>
  <div class="report-date">
    Date:
    <span class="fw-bold text-dark">
            <c:choose>
              <c:when test="${startDate == endDate}">
                ${startDate}
              </c:when>
              <c:otherwise>
                ${startDate} To ${endDate}
              </c:otherwise>
            </c:choose>
        </span>
  </div>

  <table id="reportTable" class="table align-middle">
    <thead>
    <tr>
      <th class="purple-header" style="border-top-left-radius: 8px;">Transaction ID</th>
      <th class="purple-header">Product</th>
      <th class="purple-header text-center" width="80">Qty</th>
      <th class="purple-header text-end" width="160">Amount</th>
      <th class="purple-header text-center" style="border-top-right-radius: 8px;" width="140">Payment</th>
    </tr>
    </thead>
    <tbody>
    <c:set var="grandTotalSales" value="0.0" />
    <c:set var="txnCounter" value="0" />

    <c:forEach var="row" items="${detailedSales}">
      <c:set var="grandTotalSales" value="${grandTotalSales + row.subtotal}" />
      <c:set var="txnCounter" value="${txnCounter + 1}" />
      <tr>
        <td class="text-secondary fw-medium">#SAL-${row.saleId}</td>
        <td class="fw-bold text-dark">${row.productName}</td>
        <td class="text-center fw-medium">${row.quantity}</td>
        <td class="text-end fw-bold">RM <fmt:formatNumber value="${row.subtotal}" type="number" minFractionDigits="2" maxFractionDigits="2"/></td>
        <td class="text-center">
                        <span class="badge ${row.paymentStatus == 'PAID' ? 'bg-success-subtle text-success' : 'bg-warning-subtle text-warning-dominant'} px-2 py-1">
                            ${row.paymentMethod}
                        </span>
        </td>
      </tr>
    </c:forEach>

    <c:if test="${empty detailedSales}">
      <tr>
        <td colspan="5" class="text-center text-muted py-5">No sale records found for this period.</td>
      </tr>
    </c:if>
    </tbody>

    <tfoot>
    <tr class="total-summary-row">
      <td colspan="2" class="text-end py-3">Total Sales:</td>
      <td class="text-center text-primary py-3">${txnCounter} Items</td>
      <td class="text-end text-success py-3">RM <fmt:formatNumber value="${grandTotalSales}" type="number" minFractionDigits="2" maxFractionDigits="2"/></td>
      <td class="text-center text-secondary py-3">${txnCounter} Transactions</td>
    </tr>
    </tfoot>
  </table>

  <div class="mt-4 pt-3 border-top d-flex gap-3 no-print">
    <button onclick="window.print();" class="btn btn-purple">
      <i class="bi bi-printer-fill"></i> Print Report
    </button>
    <button onclick="exportToExcel('reportTable')" class="btn btn-purple" style="background: linear-gradient(135deg, #3f51b5 0%, #5c6bc0 100%);">
      <i class="bi bi-file-earmark-excel-fill"></i> Export to Excel
    </button>
    <a href="${pageContext.request.contextPath}/reports?action=salesSummary" class="btn btn-outline-secondary px-4" style="border-radius: 8px; padding-top: 9px;">
      Exit Preview
    </a>
  </div>
</div>

<script>
  function exportToExcel(tableID, filename = 'Daily_Sales_Report') {
    // 1. 获取前端的表格对象
    var tableSelect = document.getElementById(tableID);
    if (!tableSelect) {
      alert("Error: Table ID '" + tableID + "' not found! Please check your HTML.");
      return;
    }

    // 2. 补齐 Excel 文件所需的头部编码，防止中文、RM 货币符号乱码
    var meta = '<meta http-equiv="content-type" content="application/vnd.ms-excel; charset=UTF-8">';
    var tableHTML = meta + tableSelect.outerHTML;

    // 3. 构造下载名
    var dateStr = new Date().toISOString().slice(0, 10);
    filename = filename + '_' + dateStr + '.xls';

    // 4. 使用 Blob 统一封装二进制流
    var blob = new Blob([tableHTML], {
      type: 'application/vnd.ms-excel;charset=utf-8;'
    });

    // 5. 兼容不同浏览器的下载动作
    if (navigator.msSaveOrOpenBlob) {
      navigator.msSaveOrOpenBlob(blob, filename);
    } else {
      var downloadLink = document.createElement("a");
      downloadLink.href = URL.createObjectURL(blob);
      downloadLink.download = filename;

      document.body.appendChild(downloadLink);
      downloadLink.click();
      document.body.removeChild(downloadLink);
    }
  }
</script>

</body>
</html>