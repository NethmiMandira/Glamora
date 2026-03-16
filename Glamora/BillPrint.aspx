<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BillPrint.aspx.cs" Inherits="Glamora.BillPrint" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Invoice</title>
    <style>
        :root {
            --text: #111827;
            --muted: #4b5563;
            --border: #e5e7eb;
            --bg-soft: #f9fafb;
            --accent: #111827;
        }

        * {
            box-sizing: border-box;
        }

        body {
            font-family: "Segoe UI", Arial, sans-serif;
            margin: 24px;
            color: var(--text);
            background: white;
        }

        .card {
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 20px;
            background: #fff;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .header {
            margin-bottom: 16px;
        }

        .shop-info {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            margin-bottom: 10px;
            text-align: center;
        }

        .shop-logo {
            width: 90px;
            height: 90px;
            border: 1px solid var(--border);
            border-radius: 50%;
            object-fit: cover;
            padding: 6px;
            background: #fff;
        }

        .title-row {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            gap: 16px;
            flex-wrap: wrap;
        }

        h2 {
            margin: 0;
            font-size: 22px;
            letter-spacing: 0.3px;
        }

        .meta {
            margin: 4px 0;
            color: var(--muted);
            font-size: 13px;
        }

            .meta strong {
                color: var(--text);
            }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 12px;
        }

        th, td {
            border: 1px solid var(--border);
            padding: 10px;
            font-size: 13px;
        }

        th {
            background: var(--bg-soft);
            text-align: left;
            font-weight: 600;
            letter-spacing: 0.2px;
        }

        .right {
            text-align: right;
        }

        .totals-wrap {
            display: flex;
            justify-content: flex-end;
            margin-top: 16px;
        }

        .totals {
            width: 100%;
            max-width: 360px;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 12px 14px;
            background: var(--bg-soft);
        }

        .totals-row {
            display: flex;
            justify-content: space-between;
            padding: 6px 0;
            font-size: 13px;
        }

            .totals-row strong {
                color: var(--text);
            }

        .divider {
            height: 1px;
            background: var(--border);
            margin: 6px 0;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Literal ID="litMessage" runat="server" />
        <asp:Panel ID="pnlInvoice" runat="server" CssClass="card" Visible="false">
            <div class="header">
                <div class="shop-info">
                    <asp:Image ID="imgLogo" runat="server" CssClass="shop-logo" Visible="false" />
                    <div class="meta">
                        <asp:Literal ID="litAddress" runat="server" />
                    </div>
                    <div class="meta">
                        <label>Tel :</label>
                        <asp:Literal ID="litTelephone" runat="server" />
                    </div>
                </div>
                <div class="title-row">
                    <div>
                        <div class="meta">
                            <strong>Date:</strong>
                            <asp:Literal ID="litInvoiceDate" runat="server" />
                        </div>
                        <asp:PlaceHolder ID="phAppointment" runat="server" Visible="false">
                            <div class="meta">
                                <strong>App ID:</strong>
                                <asp:Literal ID="litAppId" runat="server" />
                            </div>
                        </asp:PlaceHolder>
                        <div class="meta">
                            <strong>Customer:</strong>
                            <asp:Literal ID="litCustomer" runat="server" />
                        </div>
                    </div>
                    <div style="text-align:left;">
                        <div class="meta">
                            <strong>Invoice :</strong>
                            <asp:Literal ID="litInvoiceNo" runat="server" />
                        </div>
                        <asp:PlaceHolder ID="phAppointmentDate" runat="server" Visible="false">
                            <div class="meta">
                                <strong>App Date:</strong>
                                <asp:Literal ID="litAppDate" runat="server" />
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th style="width: 55%;">Service</th>
                        <th class="right" style="width: 15%;">Price</th>
                        <th class="right" style="width: 15%;">Discount</th>
                        <th class="right" style="width: 15%;">Total</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptServices" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("ServiceName") %></td>
                                <td class="right"><%# Eval("Price", "{0:N2}") %></td>
                                <td class="right">
                                    <%# string.Format("{0:N2} ({1:P0})", Eval("DiscountValue") ?? 0m, Eval("Discount") ?? 0m) %>
                                </td>
                                <td class="right"><%# Eval("Total", "{0:N2}") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>

            <div class="totals-wrap">
                <div class="totals">
                    <div class="totals-row">
                        <span>Gross Total</span>
                        <span><asp:Literal ID="litGrossTotal" runat="server" /></span>
                    </div>
                    <div class="totals-row">
                        <span>Additional Discount</span>
                        <span><asp:Literal ID="litAdditionalDiscount" runat="server" /></span>
                    </div>
                    <div class="totals-row">
                        <span>Advance Payment</span>
                        <span><asp:Literal ID="litAdvancePayment" runat="server" /></span>
                    </div>
                    <div class="divider"></div>
                    <div class="totals-row">
                        <strong>Net Amount</strong>
                        <strong><asp:Literal ID="litNetAmount" runat="server" /></strong>
                    </div>
                    <div class="totals-row">
                        <span>Cash Paid</span>
                        <span><asp:Literal ID="litCashPaid" runat="server" /></span>
                    </div>
                    <div class="totals-row">
                        <span>Card Paid</span>
                        <span><asp:Literal ID="litCardPaid" runat="server" /></span>
                    </div>
                    <div class="divider"></div>
                    <div class="totals-row">
                        <strong>Balance</strong>
                        <strong><asp:Literal ID="litBalance" runat="server" /></strong>
                    </div>
                </div>
            </div>
            <div class="meta">
                <asp:Literal ID="litFooterText" runat="server" />
            </div>
        </asp:Panel>
    </form>

    <script>
        window.onload = function () {
            var panel = document.getElementById('<%= pnlInvoice.ClientID %>');
            if (panel && panel.style.display !== 'none') {
                window.print();
            }
        };
    </script>
</body>
</html>
