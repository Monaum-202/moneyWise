# Moneywise — Build Progress

## Status Legend
- [ ] Not started
- [~] In progress
- [x] Complete

## Parts
- [x] Part 1: Project setup & pubspec.yaml
- [x] Part 2: Architecture scaffold & folder structure
- [x] Part 3: Data models (Freezed + Isar)
- [x] Part 4: Database layer & repositories
- [x] Part 5: Riverpod state management
- [ ] Part 6: Core screens (Dashboard + Transactions)
- [ ] Part 7: Loan module + Category module
- [ ] Part 8: Analytics, Budget, Settings & PDF export

## Dependency Versions (auto-fill after pub get)
| Package | Version |
|---------|---------|
| flutter_riverpod | ^2.5.1 |
| riverpod_annotation | ^2.3.5 |
| hooks_riverpod | ^2.5.1 |
| isar | ^3.1.0+1 |
| isar_flutter_libs | ^3.1.0+1 |
| path_provider | ^2.1.3 |
| freezed_annotation | ^2.4.4 |
| json_annotation | ^4.9.0 |
| go_router | ^14.2.0 |
| fl_chart | ^0.68.0 |
| google_fonts | ^6.2.1 |
| shimmer | ^3.0.0 |
| flutter_animate | ^4.5.0 |
| flex_color_scheme | ^7.3.1 |
| reactive_forms | ^17.0.1 |
| intl | ^0.20.2 |
| uuid | ^4.4.0 |
| logger | ^2.3.0 |
| collection | ^1.18.0 |
| local_auth | ^2.3.0 |
| flutter_secure_storage | ^9.2.2 |
| pdf | ^3.10.11 |
| printing | ^5.11.1 |
| image_picker | ^1.1.2 |
| share_plus | ^9.0.0 |
| permission_handler | ^11.3.1 |

## Notes
- Part 1 completed: Project configured with all necessary dependencies and linting rules.
- Part 5 completed: Implemented Riverpod providers for all features including state notifiers, async notifiers, and code generation.

## Providers Reference
| Provider | Type | Returns |
|----------|------|---------|
| `transactionListProvider` | `AsyncNotifier` | `Stream<List<Transaction>>` |
| `transactionSummaryProvider` | `FutureProvider` | `TransactionSummary` |
| `loanListProvider` | `AsyncNotifier` | `Stream<List<Loan>>` |
| `loanSummaryProvider` | `FutureProvider` | `({totalOwed, totalToReceive})` |
| `categoryListProvider` | `AsyncNotifier` | `Stream<List<Category>>` |
| `budgetListProvider` | `AsyncNotifier` | `Stream<List<Budget>>` |
| `categoryPieDataProvider` | `FutureProvider` | `List<PieChartSectionData>` |
| `appSettingsProvider` | `AsyncNotifier` | `ThemeMode` |

## Repository Methods
| Repository | Key Methods |
|------------|-------------|
| `Transaction` | `watchAll`, `getSummary`, `watchCategoryTotals`, `add`, `delete` |
| `Loan` | `watchAll`, `addRepayment`, `markSettled`, `getOverdue` |
| `Category` | `watchAll`, `getAll`, `add`, `update`, `delete` |
| `Budget` | `watchAll`, `getByCategory`, `setBudget`, `updateSpentAmount` |

## Data Models
| Model | Isar Collection | Key Fields |
|-------|-----------------|------------|
| `Transaction` | `Transactions` | `title`, `amount`, `date`, `type` |
| `Loan` | `Loans` | `personName`, `amount`, `type`, `date` |
| `Category` | `Categorys` | `name`, `iconCodePoint`, `colorValue` |
| `Budget` | `Budgets` | `categoryId`, `monthYear`, `limitAmount` |
| `Repayment` | (Embedded) | `amount`, `date` |

## Routing
- Dashboard: `/` (Name: `dashboard`)
- Analytics: `/analytics` (Name: `analytics`)
- Loans: `/loans` (Name: `loans`)
- Settings: `/settings` (Name: `settings`)
