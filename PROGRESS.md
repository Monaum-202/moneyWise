# Moneywise Project Progress

## Part 1: Project Setup [x]
- [x] Create Flutter project
- [x] Configure folder structure
- [x] Add dependencies

## Part 2: Core Implementation [x]
- [x] App Theme
- [x] Logger Utility
- [x] App Strings

## Part 3: Data Models [x]
- [x] Transaction Model
- [x] Loan Model
- [x] Category Model
- [x] Budget Model
- [x] Transaction Summary Model
- [x] Enums (TransactionType, LoanType, RecurringType)

## Part 4: Database & Repositories [x]
- [x] Initialize Isar with all schemas
- [x] Repository interfaces and implementations
- [x] Shared models: `CategoryTotal`, `LoanSummary`
- [x] Repository Providers
- [x] Unit tests for Repositories

## Part 5: State Management & Logic [x]
- [x] Transaction Filters & Providers
- [x] Loan Filters & Providers
- [x] Category Providers & Seeder
- [x] Budget Providers & Merged UI Model
- [x] Analytics & Insights Providers
- [x] App Settings & Secure Storage Notifier

## Part 6: Navigation & UI (Transactions) [x]
- [x] Navigation Bar & App Router
- [x] Shimmer Loading & Empty States
- [x] Dashboard Screen
- [x] Balance Summary & Insights
- [x] Transaction List & Tiles
- [x] Add Transaction Sheet

## Part 7: Features UI (Loans & Categories) [x]
- [x] Loans Module (List, Detail, Add Loan, Repayments)
- [x] Categories Module (Grid, Add Category, Icon/Color Pickers)
- [x] Biometric Lock (Lock Screen + Auto-lock logic)

## Part 8: Final Polish & Optimization [x]
- [x] Analytics Screen (Charts & Insights)
- [x] Budget Screen (Month Navigator & Monthly Limits)
- [x] Settings Screen (Preferences & Security)
- [x] Data Export/Import (JSON & PDF)
- [x] Final Theme Polish (Light/Dark mode consistency)
- [x] Routing Polish & Screen Wiring

### Screens Reference

| Screen | Route | Status |
|--------|-------|--------|
| Dashboard | / | ✓ |
| Transactions | /transactions | ✓ |
| Loans | /loans | ✓ |
| Loan Detail | /loans/:uuid | ✓ |
| Categories | /categories | ✓ |
| Analytics | /analytics | ✓ |
| Budget | /budget | ✓ |
| Settings | /settings | ✓ |
| Lock | /lock | ✓ |
| PIN Setup | /pin-setup | ✓ |

## SMS Auto-Detection ✓
- [x] Part 1: Parser (bKash, Nagad, DBBL, Rocket, IBBL)
- [x] Part 2: Live listener + providers + settings
- [x] Part 3: Confirmation card + bulk import screen
