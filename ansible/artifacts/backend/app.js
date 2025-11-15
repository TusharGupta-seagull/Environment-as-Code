import express from "express"
import cors from 'cors'
// importamos la conexión a la DB
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

try {
    await db.authenticate()
    console.log('Conexión exitosa a la DB')
} catch (error) {
    console.log(`Sequelize cannot connect to your database: ${error}`)
}



app.listen(8000, () => {
    console.log('Server UP running in http://localhost:8000/')
})
