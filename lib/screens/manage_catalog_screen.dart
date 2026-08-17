import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import 'add_product_screen.dart';
import '../providers/catalog_provider.dart';

class ManageCatalogScreen extends StatelessWidget {
  const ManageCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalogData = Provider.of<CatalogProvider>(context);
    final products = catalogData.myProducts;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        title: const Text('Katalog Saya', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PRODUK AKTIF', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                Text('${products.length} item', style: const TextStyle(color: AppTheme.neonGreen, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final prod = products[index];
                return _buildCatalogItem(context, prod);
              },
            ),
            const SizedBox(height: 16),
            
            _buildAddProductButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogItem(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF202020), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                image: product.imageUrl != null 
                    ? DecorationImage(image: NetworkImage(product.imageUrl!), fit: BoxFit.cover)
                    : null,
                gradient: product.imageUrl == null 
                    ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: product.gradientColors)
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(product.price, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddProductScreen(product: product)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8), 
                            border: Border.all(color: Colors.white.withOpacity(0.13))
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_outlined, color: Colors.white70, size: 12),
                              SizedBox(width: 4),
                              Text('Edit', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                            ],
                          )
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.glassBackground,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white12)),
                            title: const Text('Hapus Produk?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            content: Text('Apakah kamu yakin ingin menghapus "${product.title}" dari katalog?', style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.white54))),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true && context.mounted) {
                          Provider.of<CatalogProvider>(context, listen: false).removeProduct(product.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8), 
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3))
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen())),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(color: AppTheme.neonGreen.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.neonGreen.withOpacity(0.4))),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline, color: AppTheme.neonGreen, size: 36),
            SizedBox(height: 8),
            Text('Tambah Produk Baru', style: TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}