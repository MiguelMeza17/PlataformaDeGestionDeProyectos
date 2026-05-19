document.addEventListener('DOMContentLoaded', () => {

    const reportForm = document.getElementById('reportForm');
    reportForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const reporte = {
            prmOUID: document.getElementById('rOuid').value,
            prmName: document.getElementById('rName').value,
            prmDescription: document.getElementById('rDesc').value,
            prmDate: document.getElementById('rDate').value,
            prmProgressSummary: document.getElementById('rSummary').value,
            prmRetardedTasks: document.getElementById('rRetarded').value
        };

        console.log("Enviando reporte a clsReport en C#:", reporte);

    });

    async function actualizarGrafica() {

        const tareasTodo = 5;
        const tareasDoing = 3;
        const tareasDone = 12;
        
        const total = tareasTodo + tareasDoing + tareasDone;
        const porcentaje = Math.round((tareasDone / total) * 100);


        const circle = document.querySelector('.progress-circle');
        circle.style.setProperty('--progress', porcentaje + '%');
        document.getElementById('percentageText').innerText = porcentaje + '%';

        const ctx = document.getElementById('taskChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Por Hacer', 'En Desarrollo', 'Terminadas'],
                datasets: [{
                    data: [tareasTodo, tareasDoing, tareasDone],
                    backgroundColor: ['#3498db', '#f1c40f', '#2ecc71']
                }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    }

    actualizarGrafica();
});