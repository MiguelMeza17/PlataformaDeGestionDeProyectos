function moversADesarrollo(taskId) {
    const task = document.getElementById(taskId);
    if (!task) return;

    task.classList.remove('todo');
    task.classList.add('doing');

    const btn = task.querySelector('button');
    if (btn) {
        btn.innerText = "Finalizar Tarea";
        btn.onclick = () => moverATerminado(taskId);
    }

    document.getElementById('tasks-doing').appendChild(task);
}

function moverATerminado(taskId) {
    const task = document.getElementById(taskId);
    if (!task) return;

    task.classList.remove('doing');
    task.classList.add('done');

    const btn = task.querySelector('button');
    if (btn) btn.remove();

    document.getElementById('tasks-done').appendChild(task);
}