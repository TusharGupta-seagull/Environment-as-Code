import express from "express"
import cors from 'cors'
import db from "./database/db.js"

import blogRoutes from "./routes/routes.js"

const app = express()

app.use(cors({
    origin: "*",  // or your domain
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: false
}));


app.use(express.json())

app.get('/', (req, res) => {
    res.send('HOLA MUNDO')
})
app.use("/blogs", blogRoutes)

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() })
})

// Test DB connection
try {
    await db.authenticate()
    console.log('Conexión exitosa a la DB')
} catch (error) {
    console.log(`Sequelize cannot connect to your database: ${error}`)
}


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log('Server UP running in http://localhost:${PORT}/')
})
