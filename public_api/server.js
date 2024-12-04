const express = require('express');  // Mengimpor framework Express
const route = require('./src/route/index');  // Mengimpor file routes
const cors = require('cors');  // Middleware untuk mengizinkan Cross-Origin Resource Sharing
const app = express();  // Membuat instance aplikasi Express

app.use(cors());  // Mengaktifkan CORS untuk semua rute
app.use(route);  // Menggunakan routes yang sudah didefinisikan

const port = process.env.port || 3000;  // Menentukan port dari environment atau default 3000

// Menjalankan server
app.listen(port, () => {
    try {
        console.log(`Running on ${port} without you 😥`);
    } catch (error) {
        throw error;
    }
});