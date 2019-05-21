/**! @file Fail maatriksoperatsioonide jaoks */
#ifndef MATMUL_H_
#define MATMUL_H_
/*!
 * Kernelmeetod, mis kasutab lõimesid, et arvutada kiiresti maatrikskorrutis. Kasutab mälujagamist. Pole minu kirjutatud meetod.
 * @param a Viit esimesele maatriksile.
 * @param b Viit teisele maatriksile.
 * @param n Ruutmaatriksi küljepikkus.
 * @param c Viit tulemusmaatriksile.
 */
__global__ void matmul(const float* const a, const float* const b, const int n,
		float* const c);

/*!
 * Kernelmeetod, mis kasutab lõimesid, et arvutada kiiresti samakujuliste maatriksite summa.
 * @param a Viit esimesele maatriksile.
 * @param b Viit teisele maatriksile.
 * @param n Ruutmaatriksi küljepikkus.
 * @param c Viit tulemusmaatriksile.
 */
__global__ void sum(const float* const a, const float* const b, const int n,
		float* const c);

/*!
 * Meetod maatriksi välja printimiseks.
 * @param n Ruutmaatriksi elementide arv.
 * @param data Viit maatriksile.
 */
void printMat(size_t n, float *data);

/*!
 * Meetod maatriksi transponeerimiseks.
 * @param n Ruutmaatriksi elementide arv
 * @param data Viit transponeeritavale maatriksile
 * @param newData Viit tulemusmaatriksile.
 */
void transpose(size_t n, float *data, float *newData);

/*!
 * Loob uue juhusliku ruutmaatriksi.
 * @param n Ruutmaatriksi küljepikkus
 * @param hostData Viit maatriksile, kuhu juhuslikud arvud lasta curand generaatoril kirjutada.
 */
void random_matrix(size_t n, float *hostData) ;

/*!
 * Testmeetod maatrikkorrutise tegemiseks. See meetod kutsub välja maatrikskorrutise kernelmeetodi.
 * @param b Viit esimesele ruutmaatriksile
 * @param b Viit teisele maatriksile.
 * @param n Ruutmaatriksi küljepikkus.
 * @param c Viit tulemusmaatriksile.
 */
void test_matmul(const float* const b, const float* const a, const int n,
		float* const c) ;

/*!
 * Testmeetod maatriksite summeerimiseks. See meetod kutsub välja maatriksi summeerimise kernelmeetodi.
 * @param b Viit esimesele ruutmaatriksile
 * @param b Viit teisele maatriksile.
 * @param n Ruutmaatriksi küljepikkus.
 * @param c Viit tulemusmaatriksile.
 */
void test_sum(const float* const b, const float* const a, const int n,
		float* const c);

void my_mat_mul();

#endif /* MATMUL_H */
