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
