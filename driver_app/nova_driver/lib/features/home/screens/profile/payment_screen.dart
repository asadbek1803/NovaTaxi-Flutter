import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'To\'lov',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [NovaColors.amber, NovaColors.amberDark],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: NovaColors.amber.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Balans',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5C4A00),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '101 000 so\'m',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: NovaColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _showWithdrawDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: NovaColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'PUL YECHISH',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Plastik kartalar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NovaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _CardTile(
              brand: 'UzCard',
              number: '**** **** **** 4567',
              bank: 'Agrobank',
              isDefault: true,
              onTap: () {},
            ),
            _CardTile(
              brand: 'Humo',
              number: '**** **** **** 8901',
              bank: 'Ipoteka-bank',
              isDefault: false,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: OutlinedButton.icon(
                onPressed: () => _showAddCardDialog(context),
                icon: const Icon(Icons.add_card_rounded, size: 22),
                label: const Text(
                  'Karta qo\'shish',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: NovaColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oxirgi tranzaksiyalar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NovaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _TransactionTile(
              icon: Icons.add_circle_rounded,
              title: 'Balans to\'ldirish',
              subtitle: 'Karta **** 4567',
              amount: '+50 000 so\'m',
              amountColor: NovaColors.online,
              time: 'Bugun, 09:00',
            ),
            _TransactionTile(
              icon: Icons.remove_circle_rounded,
              title: 'Pul yechish',
              subtitle: 'Karta **** 4567',
              amount: '-25 000 so\'m',
              amountColor: NovaColors.danger,
              time: 'Kecha, 18:30',
            ),
            _TransactionTile(
              icon: Icons.local_taxi_rounded,
              title: 'Safar olindi',
              subtitle: 'Chilonzor → Markaziy bozor',
              amount: '+12 500 so\'m',
              amountColor: NovaColors.online,
              time: 'Kecha, 09:15',
            ),
            _TransactionTile(
              icon: Icons.add_circle_rounded,
              title: 'Balans to\'ldirish',
              subtitle: 'Karta **** 8901',
              amount: '+100 000 so\'m',
              amountColor: NovaColors.online,
              time: '24-iyul, 12:00',
            ),
            _TransactionTile(
              icon: Icons.remove_circle_rounded,
              title: 'Komissiya',
              subtitle: 'Xizmat to\'lovi',
              amount: '-5 000 so\'m',
              amountColor: NovaColors.danger,
              time: '23-iyul, 23:59',
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pul yechish',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mavjud balans: 101 000 so\'m',
                style: TextStyle(
                  fontSize: 16,
                  color: NovaColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Miqdor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NovaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: NovaColors.textPrimary,
                ),
                decoration: InputDecoration(
                  suffixText: 'so\'m',
                  suffixStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: NovaColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: NovaColors.amber, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _QuickAmountChip(amount: '10 000', onTap: () {}),
                  _QuickAmountChip(amount: '25 000', onTap: () {}),
                  _QuickAmountChip(amount: '50 000', onTap: () {}),
                  _QuickAmountChip(amount: 'Barchasi', onTap: () {}),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Karta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NovaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.credit_card_rounded, color: NovaColors.textSecondary, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agrobank · UzCard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: NovaColors.textPrimary,
                            ),
                          ),
                          Text(
                            '**** **** **** 4567',
                            style: TextStyle(
                              fontSize: 14,
                              color: NovaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle_rounded, color: NovaColors.online, size: 24),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'YECHISH',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Karta qo\'shish',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              _EditField(label: 'Karta raqami', hint: '0000 0000 0000 0000'),
              _EditField(label: 'Amal qilish muddati', hint: 'MM/YY'),
              _EditField(label: 'CVV', hint: '***'),
              _EditField(label: 'Karta egasining nomi', hint: 'Karta egasi'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'QO\'SHISH',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final String brand;
  final String number;
  final String bank;
  final bool isDefault;
  final VoidCallback onTap;

  const _CardTile({
    required this.brand,
    required this.number,
    required this.bank,
    required this.isDefault,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 40,
                  decoration: BoxDecoration(
                    color: brand == 'UzCard'
                        ? const Color(0xFF1A6D37).withValues(alpha: 0.1)
                        : const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      brand,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: brand == 'UzCard'
                            ? const Color(0xFF1A6D37)
                            : const Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        number,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: NovaColors.textPrimary,
                          fontFamily: 'monospace',
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bank,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: NovaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NovaColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Asosiy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NovaColors.amberDeep,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: NovaColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String time;

  const _TransactionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: amountColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: NovaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$subtitle · $time',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: NovaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final String amount;
  final VoidCallback onTap;

  const _QuickAmountChip({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: NovaColors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NovaColors.amber.withValues(alpha: 0.3)),
        ),
        child: Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: NovaColors.amberDeep,
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final String hint;

  const _EditField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: NovaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: NovaColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFFBDBDBD),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: NovaColors.amber, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
