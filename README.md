# LX Buy & Sell — Peer-to-Peer Student Marketplace

A relational database project built on **MySQL InnoDB** modelling a peer-to-peer marketplace for NOVA IMS students to buy and sell second-hand items. Developed for the Storing and Retrieving Data course (MSc Data Science & Advanced Analytics).

---

## Project Structure

```
lx_buy_sell/
│
├── schema + triggers + views    # Full DDL (tables, indexes, triggers, views)
├── seed data                    # 25 students, 30 listings, 28 trades, messages, reviews, reports
└── business queries             # 5 CEO-level analytical queries
```

---

## Database Schema

| Table | Description |
|---|---|
| `STUDENT` | Registered marketplace users (Active / Inactive / Banned) |
| `CATEGORY` | Item categories (Technology, Kitchenware, Appliance, Storage, Cleaning, Other) |
| `LISTING` | Items for sale with condition, price, and status lifecycle |
| `LISTING_IMAGE` | One or more images per listing, with main photo flag |
| `WISHLIST` | Students' saved listings |
| `TRADE` | Transaction records linking buyer, seller, and listing |
| `MESSAGE` | In-platform messaging between students per listing |
| `USER_REVIEW` | Post-trade ratings (as buyer / as seller), scored 1–5 |
| `REPORT` | Fraud and misconduct reports on listings or users |
| `SYSTEM_LOG` | Audit log of system events and status changes |

---

## Key Features

**Triggers**
- Validates that `TRADE.SELLER_ID` always matches `LISTING.SELLER_ID`
- Automatically sets listing to `RESERVED` when a trade is created
- Syncs listing status to `SOLD` or back to `ACTIVE` when a trade is completed or cancelled
- Logs every listing status change to `SYSTEM_LOG`

**Views**
- `vw_invoice_head_totals` — invoice summary per completed trade (buyer, seller, item, total)
- `vw_invoice_details` — line-item detail per completed trade

**Indexes**
- Optimised for seller lookups, listing status/category filtering, buyer queries, and wishlist access

---

## Business Intelligence Queries

| # | Question |
|---|---|
| Q1 | Which categories generate the highest revenue from completed trades? |
| Q2 | Who are the top sellers by volume and average rating? |
| Q3 | What is the cancellation and suspension rate by payment method? |
| Q4 | How long do deals take to complete, by category (hours)? |
| Q5 | Which users are most frequently reported and how many cases remain open? |

---

## Tools & Technologies

- **MySQL InnoDB** — relational engine with FK constraints, triggers, and views
- **SQL** — DDL, DML, aggregation, analytical queries

---

## Team

| Name | Student ID |
|---|---|
| Afonso Maia | 20250464 |
| Francisco Graça | 20250471 |
| Maria Pimentel | 20250466 |
| Renato Scotto | 20250420 |
| Rodrigo Gonçalves | 20250529 |

Nova IMS — MSc Data Science & Advanced Analytics
