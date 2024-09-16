#!/bin/bash

# Define nome do projeto
PROJECT_NAME="task-manager"

# Cria o diretório do projeto
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# Inicializa o projeto Node.js
npm init -y

# Instala as dependências
npm install express sequelize pg pg-hstore body-parser ejs

# Cria a estrutura de diretórios
mkdir -p src/{models,views,controllers}
mkdir config

# Cria o arquivo de configuração do Sequelize
cat <<EOL > config/config.json
{
  "development": {
    "username": "root",
    "password": null,
    "database": "task_manager",
    "host": "127.0.0.1",
    "dialect": "postgres"
  },
  "test": {
    "username": "root",
    "password": null,
    "database": "task_manager_test",
    "host": "127.0.0.1",
    "dialect": "postgres"
  },
  "production": {
    "username": "root",
    "password": null,
    "database": "task_manager_production",
    "host": "127.0.0.1",
    "dialect": "postgres"
  }
}
EOL

# Cria o arquivo principal do servidor
cat <<EOL > src/app.js
const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const app = express();
const port = 3000;

// Configuração do body-parser
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Configuração do EJS
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Importa e usa o controlador de tarefas
const taskController = require('./controllers/taskController');
app.use('/', taskController);

// Inicia o servidor
app.listen(port, () => {
  console.log(\`Servidor rodando em http://localhost:\${port}\`);
});

module.exports = app;
EOL

# Cria o modelo de tarefa
cat <<EOL > src/models/task.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Task = sequelize.define('Task', {
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT
  },
  completed: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
});

module.exports = Task;
EOL

# Cria o arquivo de configuração do Sequelize
cat <<EOL > src/config/database.js
const { Sequelize } = require('sequelize');
const config = require('../../config/config.json')['development'];

const sequelize = new Sequelize(config.database, config.username, config.password, {
  host: config.host,
  dialect: config.dialect
});

module.exports = sequelize;
EOL

# Cria o controlador de tarefas
cat <<EOL > src/controllers/taskController.js
const express = require('express');
const router = express.Router();
const Task = require('../models/task');

// Lista todas as tarefas
router.get('/', async (req, res) => {
  const tasks = await Task.findAll();
  res.render('index', { tasks });
});

// Cria uma nova tarefa
router.post('/tasks', async (req, res) => {
  const { title, description } = req.body;
  await Task.create({ title, description });
  res.redirect('/');
});

// Exclui uma tarefa
router.post('/tasks/delete/:id', async (req, res) => {
  const { id } = req.params;
  await Task.destroy({ where: { id } });
  res.redirect('/');
});

// Atualiza o status de uma tarefa
router.post('/tasks/update/:id', async (req, res) => {
  const { id } = req.params;
  const task = await Task.findByPk(id);
  task.completed = !task.completed;
  await task.save();
  res.redirect('/');
});

module.exports = router;
EOL

# Cria a visão para listar tarefas
cat <<EOL > src/views/index.ejs
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Task Manager</title>
</head>
<body>
  <h1>Task Manager</h1>
  <form action="/tasks" method="post">
    <input type="text" name="title" placeholder="Task title" required>
    <textarea name="description" placeholder="Task description"></textarea>
    <button type="submit">Add Task</button>
  </form>
  <ul>
    <% tasks.forEach(task => { %>
      <li>
        <%= task.title %> - <%= task.completed ? 'Completed' : 'Not Completed' %>
        <form action="/tasks/update/<%= task.id %>" method="post" style="display:inline;">
          <button type="submit"><%= task.completed ? 'Mark Incomplete' : 'Mark Complete' %></button>
        </form>
        <form action="/tasks/delete/<%= task.id %>" method="post" style="display:inline;">
          <button type="submit">Delete</button>
        </form>
      </li>
    <% }) %>
  </ul>
</body>
</html>
EOL

# Cria o script para criar e sincronizar o banco de dados
cat <<EOL > src/migrate.js
const sequelize = require('./config/database');
const Task = require('./models/task');

sequelize.sync({ force: true }).then(() => {
  console.log('Banco de dados sincronizado');
  process.exit();
});
EOL

# Mensagem final
echo "Projeto configurado. Execute 'node src/migrate.js' para criar as tabelas e 'node src/app.js' para iniciar o servidor."

