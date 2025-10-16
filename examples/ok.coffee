fill(600);
grind(30);

if (CUP > 0) { clean; } else { serve; }

while (WATER >= 200) {
  if (BEANS < 15) { grind(15); } else { clean; }
  brew;
  serve;
  clean;
}
