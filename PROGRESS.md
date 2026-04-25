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

| Model | Isar Collection | Freezed Entity |
|-------|----------------|----------------|
| Transaction | transactionModels | TransactionEntity |
| Loan | loanModels | LoanEntity |
| Category | categoryModels | CategoryEntity |
| Budget | budgetModels | BudgetEntity |

## Part 4: Database & Repositories [x]
- [x] Initialize Isar with all schemas
- [x] Create `ITransactionRepository` & `TransactionRepositoryImpl`
- [x] Create `ILoanRepository` & `LoanRepositoryImpl`
- [x] Create `ICategoryRepository` & `CategoryRepositoryImpl`
- [x] Create `IBudgetRepository` & `BudgetRepositoryImpl`
- [x] Shared models: `CategoryTotal`, `LoanSummary`
- [x] Repository Providers
- [x] Unit tests for Repositories

### Repository Methods
**Transaction Repository**
- `watchAll`: Stream of filtered transactions
- `getById`: Fetch single transaction by UUID
- `add`: Insert new transaction
- `update`: Update existing transaction
- `delete`: Remove transaction by UUID
- `getSummary`: Period totals (Income/Expense)
- `getCategoryTotals`: Grouped expenses by category

**Loan Repository**
- `watchAll`: Stream of filtered loans
- `getById`: Fetch single loan by UUID
- `add`: Insert new loan
- `update`: Update existing loan
- `delete`: Remove loan by UUID
- `addRepayment`: Append repayment to loan
- `markSettled`: Set loan as paid
- `getOverdue`: Fetch unpaid past-due loans
- `getSummary`: Loan stats (Gave/Took/Overdue)

**Category Repository**
- `watchAll`: Stream of categories
- `add`: Insert new category
- `update`: Update existing category
- `archive`: Archive category
- `seedDefaults`: Insert initial 10 categories

**Budget Repository**
- `watchByMonth`: Stream of budgets for a month
- `setLimit`: Set/Update budget limit
- `updateSpent`: Sync spent amount
- `getForCategory`: Fetch budget for specific category

## Part 5: State Management & Logic [x]
- [x] Transaction Filters & Providers
- [x] Loan Filters & Providers
- [x] Category Providers & Seeder
- [x] Budget Providers & Merged UI Model
- [x] Analytics & Insights Providers
- [x] App Settings & Secure Storage Notifier

### Providers Reference

| Provider | Type | Returns |
|----------|------|---------|
| transactionListProvider | StreamProvider | List<TransactionEntity> |
| monthlySummaryProvider | FutureProvider | TransactionSummary |
| categoryTotalsProvider | FutureProvider | List<CategoryTotal> |
| transactionFormProvider | StateNotifierProvider | TransactionEntity? |
| loanListProvider | StreamProvider | List<LoanEntity> |
| loanFormProvider | StateNotifierProvider | LoanEntity? |
| categoryListProvider | StreamProvider | List<CategoryEntity> |
| categoryMapProvider | Provider | Map<String, CategoryEntity> |
| budgetListProvider | StreamProvider | List<BudgetEntity> |
| categoryBudgetProvider | Provider | List<CategoryBudget> |
| pieChartDataProvider | Provider | List<Map<String, dynamic>> |
| barChartDataProvider | FutureProvider | List<Map<String, dynamic>> |
| insightsProvider | Provider | List<String> |
| settingsProvider | AsyncNotifierProvider | AppSettings |

## Part 6: Navigation & Layout [ ]
...
