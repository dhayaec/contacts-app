'use client';

import {
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query';
import { todoApi } from '@/lib/todoApi';
import { queryKeys } from '@/lib/queryKeys';
import type { CreateTodoInput, Todo, UpdateTodoInput } from '@/types/todo';

export function useTodos() {
  return useQuery({
    queryKey: queryKeys.todos.list(),
    queryFn: todoApi.list,
  });
}

export function useCreateTodo() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateTodoInput) => todoApi.create(input),
    onSuccess: (created) => {
      qc.setQueryData<Todo[]>(queryKeys.todos.list(), (prev) =>
        prev ? [created, ...prev] : [created]
      );
    },
  });
}

export function useUpdateTodo() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, input }: { id: number; input: UpdateTodoInput }) =>
      todoApi.update(id, input),
    onSuccess: (updated) => {
      qc.setQueryData<Todo[]>(queryKeys.todos.list(), (prev) =>
        prev ? prev.map((t) => (t.id === updated.id ? updated : t)) : prev
      );
    },
  });
}

export function useDeleteTodo() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => todoApi.remove(id),
    onMutate: async (id) => {
      await qc.cancelQueries({ queryKey: queryKeys.todos.list() });
      const previous = qc.getQueryData<Todo[]>(queryKeys.todos.list());
      qc.setQueryData<Todo[]>(queryKeys.todos.list(), (prev) =>
        prev ? prev.filter((t) => t.id !== id) : prev
      );
      return { previous };
    },
    onError: (_err, _id, ctx) => {
      if (ctx?.previous) {
        qc.setQueryData(queryKeys.todos.list(), ctx.previous);
      }
    },
    onSettled: () => {
      qc.invalidateQueries({ queryKey: queryKeys.todos.list() });
    },
  });
}
