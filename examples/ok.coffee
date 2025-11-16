fill(600);
grind(45);

if (CUP > 0) {
    clean;
}

while (WATER >= 200) {
    brew;
    serve;
    clean;
}

if (WATER > 0) {
    clean;
}
