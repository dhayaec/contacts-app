import { QueryProvider } from '@/components/QueryProvider';
import { TodoForm } from '@/components/TodoForm';
import { TodoList } from '@/components/TodoList';

export default function Home() {
  return (
    <QueryProvider>
      <main className="mx-auto min-h-screen max-w-2xl bg-gradient-to-b from-slate-50 to-slate-100 px-6 py-16 text-slate-900">
        <header className="mb-10 text-center">
          <h1 className="mb-2 text-4xl font-extrabold tracking-tight text-slate-900">
            Todo CRUD
          </h1>
          <p className="text-slate-500">Next.js + TanStack Query + JSONPlaceholder</p>
        </header>

        <section className="rounded-2xl border border-white/60 bg-white/80 p-6 shadow-xl shadow-slate-200/60 backdrop-blur">
          <h2 className="mb-4 text-lg font-semibold text-slate-800">Add Todo</h2>
          <TodoForm />
        </section>

        <section className="mt-8 rounded-2xl border border-white/60 bg-white/80 p-6 shadow-xl shadow-slate-200/60 backdrop-blur">
          <h2 className="mb-4 text-lg font-semibold text-slate-800">Todos</h2>
          <TodoList />
        </section>
      </main>
    </QueryProvider>
  );
}
