## Part 1

### Periodical Full Backups

Use `pg_dumpal`l to create a full backup:

```powershell
cd C:\Realsoftware\PostgreSQL\bin
./pg_dumpall -h localhost -U postgres > "C:\Users\effax\Desktop\full_backup.sql"
```

In code above, we first change the directory to `\bin` inside PostgreSQL's installation directory.
Then we execute `pg_dumpall.exe` in this directory with parameter `host` as `localhost`, `user` as `postgres`. And we write the output to a file named `full_backup.sql`.

We Created a task called `PostgreSQL backup` in the Task Scheduler. It will run `pg_dumpall` with above parameters at 0:00 on every day.
![](Pasted%20image%2020231130125506.png)

### Periodical Incremental Backups

```powershell
./pg_dump -h localhost -U postgres -Fc --file=C:\Users\effax\Desktop\incremental_backup.dmp sales_db
```

### Time Periods
Let's assume that the database is large and able to tolerate some data loss. Since full backup takes more space, time and other resources, we do it every one day. But Incremental takes less [[less] ]. So we do it every hour.