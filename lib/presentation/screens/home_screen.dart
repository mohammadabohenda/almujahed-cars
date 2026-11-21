// ============================================================================
// ملف: home_screen.dart
// الوظيفة: الشاشة الرئيسية للتطبيق. تعرض قائمة بجميع عقود التأجير مع شريط
// بحث فوري، وزر عائم للانتقال إلى شاشة إضافة عقد جديد، وتنتقل عند الضغط على
// أي عقد إلى شاشة تفاصيله.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/presentation/providers/contract_providers.dart';
import 'package:almugahed_cars/presentation/screens/add_edit_contract_screen.dart';
import 'package:almugahed_cars/presentation/screens/contract_details_screen.dart';
import 'package:almugahed_cars/presentation/widgets/contract_card.dart';
import 'package:almugahed_cars/presentation/widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contractsControllerProvider);
    final controller = ref.read(contractsControllerProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  AppConstants.logoPath,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_car_filled,
                      color: AppColors.secondaryWhite),
                ),
              ),
              const SizedBox(width: 10),
              const Text(AppConstants.appName),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                onChanged: controller.search,
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم، رقم اللوحة، الهاتف، الهوية...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            controller.search('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadContracts,
                child: Builder(
                  builder: (context) {
                    if (state.status == ContractsStatus.loading &&
                        state.contracts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == ContractsStatus.error) {
                      return EmptyState(
                        icon: Icons.error_outline,
                        message: state.errorMessage ?? 'حدث خطأ غير متوقع',
                      );
                    }

                    if (state.contracts.isEmpty) {
                      return EmptyState(
                        message: _searchController.text.isEmpty
                            ? 'لا توجد عقود بعد\nاضغط على + لإضافة عقد جديد'
                            : 'لا توجد نتائج مطابقة لبحثك',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: state.contracts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final contract = state.contracts[index];
                        return ContractCard(
                          contract: contract,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ContractDetailsScreen(
                                  contractId: contract.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
floatingActionButton: FloatingActionButton.extended(
  heroTag: 'fab_home_add_contract',          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddEditContractScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('عقد جديد'),
        ),
      ),
    );
  }
}
