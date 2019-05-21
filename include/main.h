#ifndef MAIN_H_
#define MAIN_H_
/*! \file Fail testimiseks */

/**
 * Meetod erinevate suurustega juhuslike ruutmaatriksite peal operatsioonide tegemiseks.
 * @param n Ruutmaatriksi külje suurus
 * @param verbose Kas printida välja maatriksid, millel operatsioone tehakse
 */
void test(size_t n, bool verbose);

/**
 * Jooksutab teste ning mõõdab kui kaua aega läheb. Maatriksite kokku korrutamine ideaalis kuupkeerukusega.
 * @return 1 kui erroreid ei ilmne.
 */
int main();

#endif /* MAIN_H */
