# Creatoo

Creatoo is a Flutter-based mobile application built for a reward-based discovery platform. Users can explore local businesses, earn rewards, and enjoy personalized experiences.

## 🚀 Features

- Onboarding flow for new users
- Business & Creator user roles
- Dynamic discount logic with loyalty points
- Wallet and rewards system
- Admin-controlled notifications (dynamic & custom)
- Clean, scalable MVVM architecture using Provider
- Firebase integration for auth, messaging, and analytics

## 🧰 Tech Stack

- **Flutter 3.27.4**
- **Dart 3.6.2**
- **Firebase (Auth, Messaging, Analytics)**
- **Flutter Native Splash**
- **Provider** for state management
- **Go Router** for navigation
- **Upgrader** for update prompts (optional)
- **SharedPreferences** for local persistence

## 🧮 Reward & Discount Logic

### 🎁 Earning Creatoo Points

- Users earn loyalty points (Creatoo Points) based on the **discount applied to their bill**.
- Formula:  
  **Points Earned = Discount Applied (%) × 2 × Final Bill Amount (after discount, before charges)**  
  _e.g.,_ If a user gets 10% discount on ₹500 bill → Bill becomes ₹450 → User earns **90 points** (10% × 2 × 450).

- Points are **business-specific**: Points earned at "Business A" can only be redeemed at "Business A".

---

### 🔄 Discount Application Rules

Each business defines:
- **First-time discount** – applied only on the first visit
- **Regular discount** – applied from the second visit onward
- **Minimum discount threshold** – enforced during redemption (visible only to admin)
- **Platform fee (PF)** and **Gateway charges** (set via admin)

---

### ✅ First Visit Flow

- User has **0 points**, so full **first-time discount** is applied.
- Points are earned as per the discount used.
- Final payable amount is:
  Discounted Amount + Gateway Charges (%) + Platform Fee


---

### 🔁 Return Visit Scenarios

#### 1. **Points exactly match discount requirement**
- Full regular discount is applied.
- All eligible points are used.
- New points are earned using the standard formula.

#### 2. **Insufficient points for full discount**
- Discount is calculated from available points using reverse calculation.
- If calculated discount ≥ minimum threshold → apply it.
- If calculated discount < minimum threshold → apply minimum discount instead.
- User's available points are fully used.
- Platform internally covers the buffer (not shown to user or business).

#### 3. **Excess points available**
- Only required points for max regular discount are deducted.
- Remaining points stay in wallet.
- Points are earned as per applied discount.

---

### 💼 Wallet Logic

- While displaying available points, a **reverse calculation** is performed using the **reverse gateway charge** (e.g., 2.30%) to estimate discount power.
- Reverse gateway and PF are configured via admin panel.

---

## 📊 Example Scenarios

---

### 🟢 First Visit Example

| Item                         | Value               |
|------------------------------|---------------------|
| Original Bill Amount         | ₹500                |
| First-Time Discount          | 10%                 |
| Discounted Amount            | ₹500 - 10% = ₹450   |
| **Creatoo Points Earned**    | 10 × 2 × ₹450 = **90 Points** |
| Gateway Charges (2.36%)      | ₹450 × 2.36% = ₹10.62 |
| Platform Fee (fixed)         | ₹5.90               |
| **Final Payable Amount**     | ₹450 + ₹10.62 + ₹5.90 = **₹466.52** |

- The user earns **90 points**, usable only at the same business.

---

### 🟡 Second Visit Example

| Item                         | Value                    |
|------------------------------|--------------------------|
| Bill Amount                  | ₹1000                   |
| Available Points             | 90                      |
| Regular Discount (max)       | 10% (needs 100 points)  |
| Min Discount Threshold       | 5% (set in admin)       |

#### 🔁 Step 1: Calculate How Much Discount User Can Claim

- Since **1 point = ₹1**, user with 90 points can claim **₹90 discount**
- On a ₹1000 bill, that is:  
  **₹90 / ₹1000 × 100 = 9% discount**

- 9% ≥ 5% minimum threshold → So, 9% discount is applied
- No buffer needed in this case

#### 💰 Step 2: Final Payment Calculation

| Item                         | Value                   |
|------------------------------|-------------------------|
| Discount Applied             | 9%                      |
| Discounted Bill              | ₹1000 - ₹90 = ₹910      |
| Gateway Charges (2.36%)      | ₹910 × 2.36% = ₹21.48    |
| Platform Fee (fixed)         | ₹5.90                   |
| **Final Payable Amount**     | ₹910 + ₹21.48 + ₹5.90 = **₹937.38** |
| **Points Earned**            | 9 × 2 × ₹910 = **163.8 Points** (rounded to 164) |

- User uses 90 points to get ₹90 discount
- Earns back 164 points from the discounted transaction

---

---

### 🔻 Scenario: User Has Less Than Minimum Discount Threshold

| Item                         | Value                      |
|------------------------------|----------------------------|
| Bill Amount                  | ₹1000                     |
| Available Points             | 30                        |
| Regular Discount (max)       | 10%                       |
| Minimum Discount Threshold   | 5%                        |
| Reverse Gateway Charge       | 2.30% (wallet view only)  |

#### 🔁 Step 1: Check Eligible Discount

- Since **1 point = ₹1**, user can claim:  
  ₹30 discount → **3%** of ₹1000

- But **3% < min threshold (5%)**, so **platform will silently provide the buffer**:
    - Points will cover 3% (₹30)
    - Platform adds remaining 2% (₹20) internally
    - Total discount applied: **5% = ₹50**

#### 💰 Step 2: Final Bill Calculation

| Item                         | Value                       |
|------------------------------|-----------------------------|
| Discount Applied             | 5% (3% from user, 2% buffer)|
| Discounted Bill              | ₹1000 - ₹50 = ₹950          |
| Gateway Charges (2.36%)      | ₹950 × 2.36% = ₹22.42       |
| Platform Fee (fixed)         | ₹5.90                       |
| **Final Payable Amount**     | ₹950 + ₹22.42 + ₹5.90 = **₹978.32** |
| **Points Earned**            | 5 × 2 × ₹950 = **95 Points** |

- **Only 30 points** are deducted from the user.
- User is shown **5% discount**.
- Platform silently covers the ₹20 shortfall.
- **User earns 95 new points** based on the 5% applied discount.

---
# creatoo_app
