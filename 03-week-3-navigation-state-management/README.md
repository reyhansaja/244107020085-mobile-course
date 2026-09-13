## Pratikum 1

<p align="center>
    <img src="screenshots/1.jpeg">
    <img src="screenshots/2.jpeg">
</p>

## Pratikum 2
<p align="center>
    <img src="screenshots/3.jpeg">
</p>

## Pratikum 3
<p align="center">
    <img src="screenshots/4.png">
    <img src="screenshots/4eror.png>
</p>

## Ai challenge
<p align="center">
    <img src="screenshots/ai.png>
</p

## Refactoring
<p align="center">
    <img src="screenshots/5.png>
</p>

## Tugas
<p align="center">
    <img src="screenshots/tugas.png>
    <img src="screenshots/tugas (2).png>
</p>

## Refleksi

1. Kapan setState masih cukup, dan kapan state harus naik ke Riverpod?
- setState cukup untuk state yang hanya digunakan satu widget, sedangkan Riverpod cocok untuk state yang digunakan banyak widget atau halaman.

2. Apa perbedaan context.go dan context.push, dan kapan masing-masing tepat digunakan?
- context.go digunakan untuk berpindah route, sedangkan context.push digunakan untuk menambahkan halaman baru ke navigation stack.

3. Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?
- AsyncValue lebih aman karena state hanya memiliki kondisi loading, data, atau error, sehingga mencegah kombinasi boolean yang tidak konsisten.