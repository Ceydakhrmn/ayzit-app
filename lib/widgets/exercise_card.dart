import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum ExerciseType {
  // Regl
  bow,
  recliningGoddess,
  legsUpWall,
  camel,
  downDog,
  child,
  butterfly,
  // 1. Trimester
  oturanKediInek,
  yanVucutEstretme,
  kolayPozBoyun,
  igneIpliktenGecirme,
  asagiBakanKopek,
  alcakHamle,
  ucgenDurusuDegistirilmis,
  oturarakOneKatlanmaGenis,
  tersSavasci,
  // 2. Trimester
  dagDurusuKolCevirme,
  sandakyeDurusu,
  savasci1,
  tersSavasci2,
  genisBacakliOneEgilme,
  tanricaComelmesi,
  yanAciPozu,
  // 3. Trimester
  boyunOmuzHareketleri,
  destekYastigiNefes,
  oturarakYanlaraEsneme,
  dizlerAcikCocukPozu,
  destekliComelme,
  dortluEsneme,
  topUzerindeKalcaDaireleri,
  duvaraDestekliKopek,
  duvara,
}

class ExerciseData {
  final String name;
  final String description;
  final List<String> benefits;
  final List<String> steps;
  final ExerciseType type;

  const ExerciseData({
    required this.name,
    required this.description,
    required this.benefits,
    required this.steps,
    required this.type,
  });
}

String exerciseImagePath(ExerciseType type) {
  switch (type) {
    case ExerciseType.bow:                      return 'assets/exercises/yay_pozu.png';
    case ExerciseType.recliningGoddess:         return 'assets/exercises/yatarak_tanrica_pozu.png';
    case ExerciseType.legsUpWall:               return 'assets/exercises/bacaklar_duvarda_pozu.png';
    case ExerciseType.camel:                    return 'assets/exercises/deve_pozu.png';
    case ExerciseType.downDog:                  return 'assets/exercises/asagi_bakan_kopek_pozu.png';
    case ExerciseType.child:                    return 'assets/exercises/cocuk_pozu.png';
    case ExerciseType.butterfly:                return 'assets/exercises/kelebek_pozu.png';
    case ExerciseType.oturanKediInek:           return 'assets/exercises/oturan_kedi_inek.png';
    case ExerciseType.yanVucutEstretme:         return 'assets/exercises/yan_vucut_esnetme.png';
    case ExerciseType.kolayPozBoyun:            return 'assets/exercises/kolay_poz_boyun.png';
    case ExerciseType.igneIpliktenGecirme:      return 'assets/exercises/igne_iplikten_gecirme.png';
    case ExerciseType.asagiBakanKopek:          return 'assets/exercises/asagi_bakan_kopek_dizler_bukulmus.png';
    case ExerciseType.alcakHamle:               return 'assets/exercises/alcak_hamle.png';
    case ExerciseType.ucgenDurusuDegistirilmis: return 'assets/exercises/ucgen_durusu_degistirilmis.png';
    case ExerciseType.oturarakOneKatlanmaGenis: return 'assets/exercises/oturarak_one_katlanma_genis_bacakli.png';
    case ExerciseType.tersSavasci:              return 'assets/exercises/savasci_2_ters_savasciya.png';
    case ExerciseType.dagDurusuKolCevirme:      return 'assets/exercises/dag_durusu_kol_cevirme.png';
    case ExerciseType.sandakyeDurusu:           return 'assets/exercises/sandalye_durusu.png';
    case ExerciseType.savasci1:                 return 'assets/exercises/savasci_1.png';
    case ExerciseType.tersSavasci2:             return 'assets/exercises/savasci_2_ters_savasciya.png';
    case ExerciseType.genisBacakliOneEgilme:    return 'assets/exercises/genis_bacakli_one_katlanma.png';
    case ExerciseType.tanricaComelmesi:         return 'assets/exercises/tanrica_comelmesi.png';
    case ExerciseType.yanAciPozu:               return 'assets/exercises/yan_aci_pozu.png';
    case ExerciseType.boyunOmuzHareketleri:     return 'assets/exercises/boyun_omuz_hareketleri.png';
    case ExerciseType.destekYastigiNefes:       return 'assets/exercises/destek_yastigi_nefes.png';
    case ExerciseType.oturarakYanlaraEsneme:    return 'assets/exercises/oturarak_yanlara_esneme.png';
    case ExerciseType.dizlerAcikCocukPozu:      return 'assets/exercises/dizler_genis_cocuk_pozu.png';
    case ExerciseType.destekliComelme:          return 'assets/exercises/destekli_comelme_duvar.png';
    case ExerciseType.dortluEsneme:             return 'assets/exercises/dortlu_esneme.png';
    case ExerciseType.topUzerindeKalcaDaireleri:return 'assets/exercises/top_kalca_cevirme.png';
    case ExerciseType.duvaraDestekliKopek:      return 'assets/exercises/duvara_destekli_kopek.png';
    case ExerciseType.duvara:                   return 'assets/exercises/duvara_destekli_kopek.png';
  }
}

class ExerciseCard extends StatelessWidget {
  final ExerciseData data;
  const ExerciseCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3D2A5E) : const Color(0xFFE9D5FF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: isDark ? 0.15 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? 'What is ${data.name} good for?'
                      : '${data.name} nelere iyi gelir?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: data.benefits.map((b) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D28D9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6D28D9).withValues(alpha: 0.45),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      b,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),

          ClipRRect(
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                exerciseImagePath(data.type),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'How to do it?' : 'Nasıl yapılır?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.steps.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => _StepCard(
                      number: i + 1,
                      text: data.steps[i],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String text;
  const _StepCard({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2840) : const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3D2A5E) : const Color(0xFFE9D5FF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
